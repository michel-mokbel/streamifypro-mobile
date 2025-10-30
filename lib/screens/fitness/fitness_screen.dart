import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import 'package:streamifypro/config/environment.dart';
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
import 'fitness_detail.dart';
import '../../core/utils/i18n.dart';

class _ParsedFitness {
  final List<ContentItem> items;
  final List<CategoryModel> categories;
  _ParsedFitness(this.items, this.categories);
}

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
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
        'fitness-$lang',
        () => _api.fetchRoute('fitness', lang),
      );
      final parsed = _parseFitnessContent(data);
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

  _ParsedFitness _parseFitnessContent(Map<String, dynamic> json) {
    final List<ContentItem> results = [];
    final List<CategoryModel> categories = [];

    final videos = json['videos'];
    final lang = context.read<LanguageProvider>().locale.languageCode;
    final originUri = Uri.parse(Environment.apiBaseUrl);


    if (videos is List) {
      for (final v in videos) {
        if (v is Map<String, dynamic>) {
          final categoryName = (lang == 'ar'
                  ? (v['category_ar']?.toString() ?? '')
                  : (v['category_en']?.toString() ?? ''))
              .trim();
          if (categoryName.isNotEmpty && !categories.any((c) => c.name == categoryName)) {
            categories.add(CategoryModel(id: categoryName, name: categoryName));
          }

          final m = <String, dynamic>{
            'id': v['id'],
            'title': v['name'] ?? '',
            'title_ar': v['name_ar'],
            'description': v['description'] ?? '',
            'description_ar': v['description_ar'],
            'url': v['url'] ?? '',
            'category': categoryName,
            // Include fitness-specific metadata
            'tips': v['tips'],
            'tips_ar': v['tips_ar'],
            'sets_reps': v['sets_reps'],
            'sets_reps_ar': v['sets_reps_ar'],
            // Build thumbnail from domain and video id
            'Thumbnail': '$originUri/assets/thumbnails/${v['id']}.jpg',
          };
          results.add(ContentItem.fromJson(m, 'fitness'));
        }
      }
    }

    return _ParsedFitness(results, categories);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activeCategoryId == null ? _items : _items.where((e) => e.category == _categories.firstWhere((c) => c.id == _activeCategoryId).name).toList();
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Fitness', ar: 'اللياقة')), actions: [
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
                            // Build same-category list and navigate
                            final sameCategory = _items.where((e) => e.category == filtered[index].category).toList();
                            final initialIndex = sameCategory.indexWhere((e) => e.id == filtered[index].id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FitnessDetailScreen(videos: sameCategory, initialIndex: initialIndex < 0 ? 0 : initialIndex),
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


