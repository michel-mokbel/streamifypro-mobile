import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';
import '../../core/api/endpoints.dart';
import '../../core/models/content_item.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/watchlater_provider.dart';
import '../../widgets/cards/game_card.dart';
import 'game_player_screen.dart';
import '../../core/utils/stats_generator.dart';
import '../../core/utils/i18n.dart';

class GameDetailScreen extends StatefulWidget {
  final ContentItem game;
  final List<ContentItem>? allGames;
  const GameDetailScreen({super.key, required this.game, this.allGames});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _ParseResult { final List<ContentItem> items; final String? categoryIcon; _ParseResult(this.items,this.categoryIcon);}  

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _loadingSimilar = true;
  List<ContentItem> _similar = [];
  String? _categoryIconUrl;

  @override
  void initState() {
    super.initState();
    if (widget.allGames != null && widget.allGames!.isNotEmpty) {
      _similar = widget.allGames!
          .where((g) => g.id != widget.game.id && (g.category == widget.game.category && g.category.isNotEmpty))
          .take(6)
          .toList();
      // Still load JSON to retrieve the category icon (and refresh similar if needed)
      _loadSimilar(preserveSimilar: true);
      _loadingSimilar = false;
    } else {
      _loadSimilar();
    }
  }

  Future<void> _loadSimilar({bool preserveSimilar = false}) async {
    try {
      final lang = context.read<LanguageProvider>().locale.languageCode;
      final url = ApiEndpoints.games(lang);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final jsonMap = json.decode(res.body) as Map<String, dynamic>;
        final parsed = _parseGamesAndIcon(jsonMap, widget.game.category);
        setState(() {
          _categoryIconUrl = parsed.categoryIcon;
          if (!preserveSimilar || _similar.isEmpty) {
            String norm(String s) => s.trim().toLowerCase();
            final target = norm(widget.game.category);
            _similar = parsed.items
                .where((g) => g.id != widget.game.id && (target.isEmpty || norm(g.category) == target))
                .take(6)
                .toList();
          }
        });
      }
    } finally {
      if (mounted) setState(() => _loadingSimilar = false);
    }
  }

  _ParseResult _parseGamesAndIcon(Map<String, dynamic> json, String targetCategory) {
    final List<ContentItem> results = [];
    String? iconUrl;
    String norm(String? s) => (s ?? '').trim().toLowerCase();
    final normTarget = norm(targetCategory);
    final content = json['Content'];
    if (content is List) {
      for (final group in content) {
        if (group is Map<String, dynamic> && group['HTML5'] is List) {
          for (final cat in group['HTML5']) {
            if (cat is Map<String, dynamic>) {
              final catName = cat['Name']?.toString() ?? '';
              if (iconUrl == null && (normTarget.isEmpty || norm(catName) == normTarget)) {
                iconUrl = cat['Icon']?.toString();
              }
              final items = cat['Content'];
              if (items is List) {
                for (final item in items) {
                  if (item is Map<String, dynamic>) {
                    final m = Map<String, dynamic>.from(item);
                    m['category'] = catName;
                    results.add(ContentItem.fromJson(m, 'game'));
                  }
                }
              }
            }
          }
        }
      }
    }
    return _ParseResult(results, iconUrl);
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final later = context.watch<WatchLaterProvider>();
    final game = widget.game;
    return Scaffold(
      appBar: AppBar(title: Text(localizedTitle(context, game))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: game.thumbnail,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (c, u) => Shimmer.fromColors(
                baseColor: AppColors.cardBg,
                highlightColor: AppColors.cardHoverBg,
                child: Container(height: 200, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(localizedTitle(context, game), style: AppTypography.heading1),
          const SizedBox(height: 8),
          Text(localizedDescription(context, game), style: AppTypography.bodyText),
          const SizedBox(height: 16),
          // Play button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GamePlayerScreen(game: game)),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(t(context, en: 'Play', ar: 'تشغيل')),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                backgroundColor: AppColors.accentPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(icon: Icons.sports_esports, label: t(context, en: 'Plays', ar: 'مرات اللعب'), value: StatsGenerator.formatCompactInt(StatsGenerator.plays('game:${game.id}'))),
              _Stat(icon: Icons.visibility, label: t(context, en: 'Views', ar: 'المشاهدات'), value: StatsGenerator.formatCompactInt(StatsGenerator.views('game:${game.id}'))),
              _Stat(icon: Icons.star, label: t(context, en: 'Rating', ar: 'التقييم'), value: '${StatsGenerator.rating('game:${game.id}')} / 5'),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Row(children: [
            IconButton(
              icon: Icon(favs.isFavorite(game.id) ? Icons.favorite : Icons.favorite_border),
              color: favs.isFavorite(game.id) ? AppColors.accentDanger : AppColors.textSecondary,
              onPressed: () => favs.toggleFavorite(game),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(later.isWatchLater(game.id) ? Icons.watch_later : Icons.watch_later_outlined),
              color: later.isWatchLater(game.id) ? AppColors.accentPrimary : AppColors.textSecondary,
              onPressed: () => later.toggleWatchLater(game),
            ),
          ]),
          const SizedBox(height: 16),
          // Category card
          Text(t(context, en: 'Category', ar: 'الفئة'), style: AppTypography.heading2),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (_categoryIconUrl != null && _categoryIconUrl!.isNotEmpty)
                      ? CachedNetworkImage(imageUrl: _categoryIconUrl!, width: 56, height: 56, fit: BoxFit.cover)
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: AppColors.cardHoverBg, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.videogame_asset, color: AppColors.textMuted),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((game.category.isEmpty ? t(context, en: 'Games', ar: 'الألعاب') : localizedCategory(context, game)), style: AppTypography.heading2),
                      const SizedBox(height: 4),
                      Text(t(context, en: 'Similar games below', ar: 'ألعاب مشابهة بالأسفل'), style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Similar games
          Text(t(context, en: 'Similar Games', ar: 'ألعاب مشابهة'), style: AppTypography.heading2),
          const SizedBox(height: 8),
          if (_loadingSimilar)
            Shimmer.fromColors(
              baseColor: AppColors.cardBg,
              highlightColor: AppColors.cardHoverBg,
              child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            )
          else
            Column(
              children: _similar
                  .map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GameCard(
                          item: g,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GameDetailScreen(game: g)),
                            );
                          },
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
      
    );
  }

}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 18, color: AppColors.textMuted), const SizedBox(width: 6), Text(label, style: AppTypography.caption)]),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.heading2),
        ],
      ),
    );
  }
}


