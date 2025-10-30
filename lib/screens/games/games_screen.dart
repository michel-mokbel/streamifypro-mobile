import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../core/api/api_cache.dart';
import '../../core/api/api_client.dart';
import '../../core/models/content_item.dart';
import '../../core/models/category.dart';
import '../../providers/language_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/watchlater_provider.dart';
import '../../widgets/cards/game_card.dart';
import '../../widgets/cards/category_bubble.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/navigation/side_drawer.dart';
import 'game_detail.dart';
import '../../core/utils/i18n.dart';

class _ParsedGames {
  final List<ContentItem> items;
  final List<CategoryModel> categories;
  _ParsedGames(this.items, this.categories);
}

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final ApiClient _api = ApiClient();
  bool _loading = true;
  String? _error;
  List<ContentItem> _items = [];
  List<CategoryModel> _categories = [];
  String? _activeCategoryId;
  static const int _pageSize = 20;
  int _visibleCount = 20;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lang = context.read<LanguageProvider>().locale.languageCode;
      final data = await ApiCache.getCachedData<Map<String, dynamic>>(
        'games-$lang',
        () => _api.fetchRoute('games', lang),
      );
      final parsed = _parseGamesContent(data);
      setState(() {
        _items = parsed.items;
        _categories = parsed.categories;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  _ParsedGames _parseGamesContent(Map<String, dynamic> json) {
    final List<ContentItem> results = [];
    final List<CategoryModel> categories = [];
    void traverse(dynamic node, {CategoryModel? category}) {
      if (node is Map<String, dynamic>) {
        if (node.containsKey('Content') && node['Content'] is String) {
          final m = Map<String, dynamic>.from(node);
          if (category != null) m['category'] = category.name;
          if (category?.nameAr != null) m['category_ar'] = category!.nameAr;
          results.add(ContentItem.fromJson(m, 'game'));
        }
        if (node['HTML5'] is List) {
          for (final child in node['HTML5']) {
            traverse(child, category: category);
          }
        }
        if (node['Content'] is List) {
          for (final child in node['Content']) {
            traverse(child, category: category);
          }
        }
        if (node['Name'] != null) {
          final cat = CategoryModel.fromJson(node);
          categories.add(cat);
          if (node['HTML5'] is List) {
            for (final child in node['HTML5']) {
              traverse(child, category: cat);
            }
          }
        }
      } else if (node is List) {
        for (final child in node) {
          traverse(child, category: category);
        }
      }
    }
    traverse(json['Content']);
    return _ParsedGames(results, categories);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activeCategoryId == null ? _items : _items.where((e) => e.category == _categories.firstWhere((c) => c.id == _activeCategoryId).name).toList();
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Games', ar: 'الألعاب')), actions: [
        IconButton(onPressed: () => Navigator.pushNamed(context, '/search'), icon: const Icon(Icons.search)),
      ]),
      drawer: const SideDrawer(),
      body: _loading
          ? const LoadingIndicator()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.accentPrimary,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // no inline search
                      if (_categories.isNotEmpty)
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return CategoryBubble(
                                  name: t(context, en: 'All', ar: 'الكل'),
                                  isActive: _activeCategoryId == null,
                                  onTap: () => setState(() => _activeCategoryId = null),
                                );
                              }
                              final cat = _categories[index - 1];
                              return CategoryBubble(
                                name: t(context, en: cat.name, ar: (cat.nameAr ?? cat.name)),
                                iconUrl: cat.icon,
                                isActive: _activeCategoryId == cat.id,
                                onTap: () => setState(() => _activeCategoryId = cat.id),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemCount: _categories.length + 1,
                          ),
                        ),
                      if (_categories.isNotEmpty) const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filtered.length < _visibleCount ? filtered.length : _visibleCount,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final favs = context.watch<FavoritesProvider>();
                          final later = context.watch<WatchLaterProvider>();
                          return GameCard(
                            item: item,
                            isFavorite: favs.isFavorite(item.id),
                            isWatchLater: later.isWatchLater(item.id),
                            onToggleFavorite: () => favs.toggleFavorite(item),
                            onToggleWatchLater: () => later.toggleWatchLater(item),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GameDetailScreen(game: item, allGames: filtered),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (_visibleCount < filtered.length) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _visibleCount += _pageSize),
                            child: Text(t(context, en: 'Load more', ar: 'عرض المزيد')),
                          ),
                        ),
                      ],
                    ],
                ),
                ),
      
    );
  }
}


