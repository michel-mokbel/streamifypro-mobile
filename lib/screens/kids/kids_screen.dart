import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../core/api/api_cache.dart';
import '../../core/api/api_client.dart';
import '../../core/models/content_item.dart';
import '../../core/models/category.dart';
import '../../providers/language_provider.dart';
import '../../widgets/cards/video_card.dart';
import '../../widgets/cards/category_bubble.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/navigation/side_drawer.dart';
import '../streaming/video_detail.dart';
import '../../core/utils/i18n.dart';

class _ParsedKids {
  final List<ContentItem> items;
  final List<CategoryModel> categories;
  _ParsedKids(this.items, this.categories);
}

class KidsScreen extends StatefulWidget {
  const KidsScreen({super.key});

  @override
  State<KidsScreen> createState() => _KidsScreenState();
}

class _KidsScreenState extends State<KidsScreen> {
  final ApiClient _api = ApiClient();
  bool _loading = true;
  String? _error;
  List<ContentItem> _items = [];
  List<CategoryModel> _categories = [];
  String? _activeCategoryId;
  String _query = '';
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
        'kids-$lang',
        () => _api.fetchRoute('kids', lang),
      );
      final parsed = _parseKidsContent(data);
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

  _ParsedKids _parseKidsContent(Map<String, dynamic> json) {
    final List<ContentItem> results = [];
    final List<CategoryModel> categories = [];

    final channels = json['channels'];
    if (channels is List) {
      for (final ch in channels) {
        if (ch is Map<String, dynamic>) {
          final channelName = ch['name']?.toString() ?? 'Channel';
          final channelNameAr = ch['name_ar']?.toString();
          final channelId = (ch['id'] ?? channelName).toString();
          categories.add(CategoryModel(id: channelId, name: channelName, icon: ch['profileImage']?.toString(), nameAr: channelNameAr));

          final playlists = ch['playlists'];
          if (playlists is List) {
            for (final pl in playlists) {
              if (pl is Map<String, dynamic>) {
                final content = pl['content'];
                if (content is List) {
                  for (final item in content) {
                    if (item is Map<String, dynamic>) {
                      final m = <String, dynamic>{
                        'id': item['id'],
                        'title': item['title'] ?? '',
                        'description': item['description'] ?? '',
                        'title_ar': item['title_ar'],
                        'description_ar': item['description_ar'],
                        'imageCropped': item['imageCropped'] ?? item['imageFile'] ?? '',
                        'sourceFile': item['sourceFile'] ?? '',
                        'category': channelName,
                        'category_ar': channelNameAr,
                      };
                      results.add(ContentItem.fromJson(m, 'kids'));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return _ParsedKids(results, categories);
  }

  @override
  Widget build(BuildContext context) {
    final byQuery = _query.isEmpty ? _items : _items.where((e) => e.title.toLowerCase().contains(_query.toLowerCase())).toList();
    final filtered = _activeCategoryId == null ? byQuery : byQuery.where((e) => e.category == _categories.firstWhere((c) => c.id == _activeCategoryId).name).toList();
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Kids', ar: 'الأطفال'))),
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
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (q) => setState(() => _query = q),
                      ),
                      const SizedBox(height: 16),
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
                                name: cat.name,
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
                      if (filtered.isEmpty)
                        Center(child: Text(t(context, en: 'No items found', ar: 'لا توجد عناصر')))
                      else
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
                        itemBuilder: (context, index) => VideoCard(
                          item: filtered[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoDetailScreen(video: filtered[index]),
                              ),
                            );
                          },
                        ),
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


