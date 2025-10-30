import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../core/api/api_cache.dart';
import '../../core/api/api_client.dart';
import '../../core/models/content_item.dart';
import '../../providers/language_provider.dart';
import '../../core/models/category.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/watchlater_provider.dart';
import '../../widgets/cards/video_card.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/navigation/side_drawer.dart';
import 'video_detail.dart';
import '../../widgets/cards/category_bubble.dart';
import '../../core/utils/i18n.dart';

class _Parsed {
  final List<ContentItem> items;
  final List<CategoryModel> categories;
  _Parsed(this.items, this.categories);
}

class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
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
        'streaming-$lang',
        () => _api.fetchRoute('streaming', lang),
      );
      final parsed = _parseStreamingContent(data);
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

  List<ContentItem> _attachCategory(List<ContentItem> items, String categoryName, {String? categoryNameAr}) {
    return items
        .map((it) => ContentItem(
              id: it.id,
              title: it.title,
              description: it.description,
              thumbnail: it.thumbnail,
              url: it.url,
              duration: it.duration,
              views: it.views,
              rating: it.rating,
              isPremium: it.isPremium,
              category: categoryName,
              type: it.type,
              metadata: {
                ...it.metadata,
                if (categoryNameAr != null && categoryNameAr.isNotEmpty) 'category_ar': categoryNameAr,
              },
            ))
        .toList();
  }

  _Parsed _parseStreamingContent(Map<String, dynamic> json) {
    final List<ContentItem> results = [];
    final List<CategoryModel> categories = [];
    final content = json['Content'];
    if (content is List && content.isNotEmpty) {
      final videosContainer = content.first['Videos'];
      if (videosContainer is List) {
        for (final category in videosContainer) {
          final items = category['Content'];
          final catModel = CategoryModel.fromJson(category as Map<String, dynamic>);
          categories.add(catModel);
          if (items is List) {
            final catItems = items
                .whereType<Map<String, dynamic>>()
                .map((m) => ContentItem.fromJson(m, 'streaming'))
                .toList();
            results.addAll(_attachCategory(catItems, catModel.name, categoryNameAr: catModel.nameAr));
          }
        }
      }
    }
    return _Parsed(results, categories);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activeCategoryId == null
        ? _items
        : _items.where((e) => e.category == _categories.firstWhere((c) => c.id == _activeCategoryId).name).toList();
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Streaming', ar: 'البث')), actions: [
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
                      return VideoCard(
                        item: item,
                        isFavorite: favs.isFavorite(item.id),
                        isWatchLater: later.isWatchLater(item.id),
                        onToggleFavorite: () => favs.toggleFavorite(item),
                        onToggleWatchLater: () => later.toggleWatchLater(item),
                        onTap: () {
                          final catName = item.category;
                          final sameCategory = _items.where((e) => e.category == catName).toList();
                          final initialIndex = sameCategory.indexWhere((e) => e.id == item.id);
                          final cat = _categories.firstWhere((c) => c.name == catName, orElse: () => CategoryModel(id: '', name: catName));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoDetailScreen(
                                video: item,
                                playlistVideos: sameCategory,
                                initialIndex: initialIndex < 0 ? 0 : initialIndex,
                                categoryName: cat.name,
                                
                              ),
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


