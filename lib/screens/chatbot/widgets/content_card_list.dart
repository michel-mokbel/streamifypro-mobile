import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/models/chatbot_models.dart';
import '../../../core/models/content_item.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_cache.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';
import '../../streaming/video_detail.dart';
import '../../games/game_detail.dart';
import '../../kids/kids_video_detail.dart';
import '../../../core/utils/i18n.dart';
import '../../../core/utils/fuzzy.dart';
import '../../../config/theme.dart';

class ContentCardList extends StatelessWidget {
  final List<ChatbotItem> items;

  const ContentCardList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ContentCard(item: items[index]);
        },
      ),
    );
  }
}

class ContentCard extends StatefulWidget {
  final ChatbotItem item;

  const ContentCard({super.key, required this.item});

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  String? _displayTitle;
  String? _displayCategory;

  @override
  void initState() {
    super.initState();
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    try {
      final ContentItem? resolved = await _resolveContentForDisplay(context, widget.item);
      if (!mounted) return;
      if (resolved != null) {
        setState(() {
          _displayTitle = localizedTitle(context, resolved);
          _displayCategory = localizedCategory(context, resolved);
        });
      } else {
        // Fallback category mapping
        setState(() {
          _displayCategory = _localizeCategoryString(context, widget.item.category);
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _displayCategory = _localizeCategoryString(context, widget.item.category);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatbotItem item = widget.item;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.thumbnail,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: AppColors.cardHoverBg,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: AppColors.cardHoverBg,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
                if (item.durationSec > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.getFormattedDuration(),
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          item.type == 'video' ? AppColors.accentSuccess : AppColors.accentWarning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      t(
                        context,
                        en: item.type.toUpperCase(),
                        ar: item.type.toLowerCase() == 'game' ? 'لعبة' : 'فيديو',
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayTitle ?? item.title,
                      style: AppTypography.heading2.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if ((_displayCategory ?? item.category) != null)
                      Text(
                        (_displayCategory ?? item.category)!,
                        style: AppTypography.caption.copyWith(color: AppColors.accentPrimary),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _openChatbotItem(context, item);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(t(context, en: 'Open', ar: 'فتح')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<ContentItem?> _resolveContentForDisplay(BuildContext context, ChatbotItem item) async {
  final String lang = context.read<LanguageProvider>().locale.languageCode;
  final ApiClient api = ApiClient();
  String source = item.source.toLowerCase();
  if (source.isEmpty) source = item.type.toLowerCase() == 'game' ? 'games' : 'streaming';

  if (source == 'games') {
    final data = await ApiCache.getCachedData<Map<String, dynamic>>('games-$lang', () => api.fetchRoute('games', lang));
    final List<ContentItem> games = _parseGames(data);
    ContentItem? found = games.firstWhere(
      (g) => g.id == item.id || g.title == item.title,
      orElse: () => const ContentItem(id: '', title: '', description: '', thumbnail: '', url: '', duration: '0', views: 0, rating: 0, isPremium: false, category: '', type: 'game'),
    );
    if (found.id.isEmpty) {
      double best = 0;
      for (final g in games) {
        final s = Fuzzy.score(item.title, g.title);
        if (s > best) { best = s; found = g; }
      }
      if (best < 0.3) return null;
    }
    return found;
  }

  if (source == 'kids') {
    final data = await ApiCache.getCachedData<Map<String, dynamic>>('kids-$lang', () => api.fetchRoute('kids', lang));
    final _KidsLookup? lookup = _findKidsPlaylistAndVideo(data, item);
    if (lookup == null || lookup.videos.isEmpty) return null;
    final int idx = lookup.videos.indexWhere((v) => v.id == (Uri.tryParse(item.detailUrl)?.queryParameters['video'] ?? item.id));
    return lookup.videos[idx >= 0 ? idx : 0];
  }

  // streaming/fitness
  final String route = (source == 'fitness') ? 'fitness' : 'streaming';
  final data = await ApiCache.getCachedData<Map<String, dynamic>>('$route-$lang', () => api.fetchRoute(route, lang));
  final _StreamingParsed parsed = _parseStreaming(data);
  ContentItem? target = parsed.items.firstWhere(
    (v) => v.id == item.id || v.title == item.title,
    orElse: () => const ContentItem(id: '', title: '', description: '', thumbnail: '', url: '', duration: '0', views: 0, rating: 0, isPremium: false, category: '', type: 'streaming'),
  );
  if (target.id.isEmpty) {
    double best = 0;
    for (final v in parsed.items) {
      final s = Fuzzy.score(item.title, v.title);
      if (s > best) { best = s; target = v; }
    }
    if (best < 0.3) return null;
  }
  return target;
}

String? _localizeCategoryString(BuildContext context, String? category) {
  if (category == null) return null;
  final map = {
    'alphabet': 'الحروف الأبجدية',
    'animals': 'الحيوانات',
    'numbers': 'الأرقام',
    'stories': 'قصص',
    'science': 'علوم',
    'dance': 'رقص',
    'games': 'الألعاب',
    'fitness': 'اللياقة',
    'music': 'موسيقى',
    'cartoons': 'رسوم متحركة',
    'educational': 'تعليمي',
  };
  return isArabic(context) ? (map[category.toLowerCase()] ?? category) : category;
}


Future<void> _openChatbotItem(BuildContext context, ChatbotItem item) async {
  final String lang = context.read<LanguageProvider>().locale.languageCode;
  final ApiClient api = ApiClient();

  String source = item.source.toLowerCase();
  if (source.isEmpty) {
    source = item.type.toLowerCase() == 'game' ? 'games' : 'streaming';
  }

  if (source == 'games') {
    final data = await ApiCache.getCachedData<Map<String, dynamic>>(
      'games-$lang',
      () => api.fetchRoute('games', lang),
    );
    final List<ContentItem> games = _parseGames(data);
    final ContentItem game = games.firstWhere(
      (g) => g.id == item.id,
      orElse: () => games.firstWhere((g) => g.title == item.title, orElse: () => const ContentItem(id: '', title: '', description: '', thumbnail: '', url: '', duration: '0', views: 0, rating: 0, isPremium: false, category: '', type: 'game')),
    );
    if (game.id.isEmpty) {
      _showNotFound(context);
      return;
    }
    // Navigate to Game
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
    );
    return;
  }

  if (source == 'kids') {
    final data = await ApiCache.getCachedData<Map<String, dynamic>>(
      'kids-$lang',
      () => api.fetchRoute('kids', lang),
    );
    final _KidsLookup? lookup = _findKidsPlaylistAndVideo(data, item);
    if (lookup == null) {
      _showNotFound(context);
      return;
    }
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KidsVideoDetailScreen(
          playlistVideos: lookup.videos,
          initialIndex: lookup.initialIndex,
          playlistName: lookup.playlistName,
          playlistImage: lookup.playlistImage,
        ),
      ),
    );
    return;
  }

  // streaming or fitness (treated similarly for navigation)
  final String route = (source == 'fitness') ? 'fitness' : 'streaming';
  final data = await ApiCache.getCachedData<Map<String, dynamic>>(
    '$route-$lang',
    () => api.fetchRoute(route, lang),
  );
  final _StreamingParsed parsed = _parseStreaming(data);
  final ContentItem target = parsed.items.firstWhere(
    (v) => v.id == item.id,
    orElse: () => parsed.items.firstWhere((v) => v.title == item.title, orElse: () => const ContentItem(id: '', title: '', description: '', thumbnail: '', url: '', duration: '0', views: 0, rating: 0, isPremium: false, category: '', type: 'streaming')),
  );
  if (target.id.isEmpty) {
    _showNotFound(context);
    return;
  }
  final List<ContentItem> sameCategory = parsed.items.where((e) => e.category == target.category).toList();
  final int idx = sameCategory.indexWhere((e) => e.id == target.id);
  // ignore: use_build_context_synchronously
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VideoDetailScreen(
        video: target,
        playlistVideos: sameCategory,
        initialIndex: idx < 0 ? 0 : idx,
        categoryName: target.category,
      ),
    ),
  );
}

void _showNotFound(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Content not found')),
  );
}

class _StreamingParsed {
  final List<ContentItem> items;
  _StreamingParsed(this.items);
}

_StreamingParsed _parseStreaming(Map<String, dynamic> json) {
  final List<ContentItem> results = [];
  final content = json['Content'];
  if (content is List && content.isNotEmpty) {
    final videosContainer = content.first['Videos'];
    if (videosContainer is List) {
      for (final category in videosContainer) {
        if (category is Map<String, dynamic>) {
          final catName = category['Name']?.toString() ?? category['name']?.toString() ?? '';
          final items = category['Content'];
          if (items is List) {
            for (final it in items) {
              if (it is Map<String, dynamic>) {
                final mapped = ContentItem.fromJson(it, 'streaming');
                results.add(ContentItem(
                  id: mapped.id,
                  title: mapped.title,
                  description: mapped.description,
                  thumbnail: mapped.thumbnail,
                  url: mapped.url,
                  duration: mapped.duration,
                  views: mapped.views,
                  rating: mapped.rating,
                  isPremium: mapped.isPremium,
                  category: catName,
                  type: mapped.type,
                ));
              }
            }
          }
        }
      }
    }
  }
  return _StreamingParsed(results);
}

class _KidsLookup {
  final List<ContentItem> videos;
  final int initialIndex;
  final String playlistName;
  final String? playlistImage;
  _KidsLookup(this.videos, this.initialIndex, this.playlistName, this.playlistImage);
}

_KidsLookup? _findKidsPlaylistAndVideo(Map<String, dynamic> json, ChatbotItem item) {
  final Uri uri = Uri.tryParse(item.detailUrl) ?? Uri();
  final String? qChannel = uri.queryParameters['channel'];
  final String? qPlaylist = uri.queryParameters['playlist'];
  final String targetVideoId = uri.queryParameters['video'] ?? item.id;

  final channels = json['channels'];
  if (channels is List) {
    for (final ch in channels) {
      if (ch is Map<String, dynamic>) {
        final String channelId = (ch['id'] ?? '').toString();
        final String channelName = ch['name']?.toString() ?? '';
        final String channelNameAr = ch['name_ar']?.toString() ?? '';
        final bool channelMatch = (item.channelId != null && item.channelId!.isNotEmpty && item.channelId == channelId) ||
            (qChannel != null && qChannel.isNotEmpty && (qChannel == channelId || qChannel == channelName));
        if (!channelMatch && (item.channelId != null || qChannel != null)) {
          continue;
        }

        final playlists = ch['playlists'];
        if (playlists is List) {
          for (final pl in playlists) {
            if (pl is Map<String, dynamic>) {
              final String plName = pl['name']?.toString() ?? '';
              final String plId = (pl['id'] ?? '').toString();
              final bool playlistMatch = (item.playlistId != null && item.playlistId!.isNotEmpty && item.playlistId == plId) ||
                  (qPlaylist != null && qPlaylist.isNotEmpty && (qPlaylist == plId || qPlaylist == plName)) ||
                  (item.playlistId == null && qPlaylist == null); // if unspecified, first playlist

              if (!playlistMatch) continue;

              final List<ContentItem> videos = [];
              final content = pl['content'];
              if (content is List) {
                for (final it in content) {
                  if (it is Map<String, dynamic>) {
                    final m = <String, dynamic>{
                      'id': it['id'],
                      'title': it['title'] ?? '',
                      'description': it['description'] ?? '',
                      'title_ar': it['title_ar'],
                      'description_ar': it['description_ar'],
                      'imageCropped': it['imageCropped'] ?? it['imageFile'] ?? '',
                      'sourceFile': it['sourceFile'] ?? '',
                      'category': channelName,
                      'category_ar': channelNameAr,
                    };
                    videos.add(ContentItem.fromJson(m, 'kids'));
                  }
                }
              }
              final int idx = videos.indexWhere((v) => v.id == targetVideoId);
              return _KidsLookup(videos, idx < 0 ? 0 : idx, plName, pl['profileImage']?.toString());
            }
          }
        }
      }
    }
  }
  return null;
}

List<ContentItem> _parseGames(Map<String, dynamic> json) {
  final List<ContentItem> results = [];
  final content = json['Content'];
  if (content is List) {
    for (final group in content) {
      if (group is Map<String, dynamic> && group['HTML5'] is List) {
        for (final cat in group['HTML5']) {
          if (cat is Map<String, dynamic>) {
            final String catName = cat['Name']?.toString() ?? '';
            final items = cat['Content'];
            if (items is List) {
              for (final it in items) {
                if (it is Map<String, dynamic>) {
                  final m = Map<String, dynamic>.from(it);
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
  return results;
}


