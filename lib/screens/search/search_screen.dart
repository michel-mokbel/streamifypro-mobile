import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../core/utils/fuzzy.dart';

import '../../core/api/endpoints.dart';
import '../../core/models/content_item.dart';
import '../../widgets/cards/game_card.dart';
import '../../widgets/cards/video_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../core/utils/i18n.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _category = 'all';
  String _query = '';
  bool _loading = false;
  String? _error;
  List<ContentItem> _results = [];
  Timer? _debounce;

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      List<ContentItem> items = [];
      final lang = context.read<LanguageProvider>().locale.languageCode;
      if (_category == 'all') {
        final responses = await Future.wait([
          http.get(Uri.parse(ApiEndpoints.streaming(lang))),
          http.get(Uri.parse(ApiEndpoints.games(lang))),
          http.get(Uri.parse(ApiEndpoints.kids(lang))),
          http.get(Uri.parse(ApiEndpoints.fitness(lang))),
        ]);
        if (responses[0].statusCode == 200) {
          items.addAll(_parseStreaming(json.decode(responses[0].body) as Map<String, dynamic>));
        }
        if (responses[1].statusCode == 200) {
          items.addAll(_parseGames(json.decode(responses[1].body) as Map<String, dynamic>));
        }
        if (responses[2].statusCode == 200) {
          items.addAll(_parseKids(json.decode(responses[2].body) as Map<String, dynamic>));
        }
        if (responses[3].statusCode == 200) {
          items.addAll(_parseFitness(json.decode(responses[3].body) as Map<String, dynamic>));
        }
      } else {
        late final String url;
        if (_category == 'streaming') {
          url = ApiEndpoints.streaming(lang);
        } else if (_category == 'games') {
          url = ApiEndpoints.games(lang);
        } else if (_category == 'kids') {
          url = ApiEndpoints.kids(lang);
        } else {
          url = ApiEndpoints.fitness(lang);
        }
        final res = await http.get(Uri.parse(url));
        if (res.statusCode != 200) throw Exception('Failed');
        final jsonMap = json.decode(res.body) as Map<String, dynamic>;
        switch (_category) {
          case 'streaming':
            items = _parseStreaming(jsonMap);
            break;
          case 'games':
            items = _parseGames(jsonMap);
            break;
          case 'kids':
            items = _parseKids(jsonMap);
            break;
          case 'fitness':
          default:
            items = _parseFitness(jsonMap);
        }
      }
      final q = _query.trim();
      if (q.isNotEmpty) {
        items.sort((a, b) => Fuzzy.score(q, localizedTitle(context, b)).compareTo(Fuzzy.score(q, localizedTitle(context, a))));
        items = items.where((e) => Fuzzy.score(q, localizedTitle(context, e)) > 0.2).toList();
      }
      setState(() => _results = items);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<ContentItem> _parseStreaming(Map<String, dynamic> json) {
    final List<ContentItem> out = [];
    final content = json['Content'];
    if (content is List && content.isNotEmpty) {
      final videosContainer = content.first['Videos'];
      if (videosContainer is List) {
        for (final cat in videosContainer) {
          final items = cat['Content'];
          if (items is List) {
            for (final it in items) {
              if (it is Map<String, dynamic>) {
                out.add(ContentItem.fromJson(it, 'streaming'));
              }
            }
          }
        }
      }
    }
    return out;
  }

  List<ContentItem> _parseGames(Map<String, dynamic> json) {
    final List<ContentItem> out = [];
    final content = json['Content'];
    if (content is List) {
      for (final group in content) {
        if (group is Map<String, dynamic> && group['HTML5'] is List) {
          for (final cat in group['HTML5']) {
            if (cat is Map<String, dynamic> && cat['Content'] is List) {
              final name = cat['Name']?.toString() ?? '';
              for (final it in cat['Content']) {
                if (it is Map<String, dynamic>) {
                  final m = Map<String, dynamic>.from(it);
                  m['category'] = name;
                  out.add(ContentItem.fromJson(m, 'game'));
                }
              }
            }
          }
        }
      }
    }
    return out;
  }

  List<ContentItem> _parseKids(Map<String, dynamic> json) {
    final List<ContentItem> out = [];
    final channels = json['channels'];
    if (channels is List) {
      for (final ch in channels) {
        if (ch is Map<String, dynamic>) {
          final channelName = ch['name']?.toString() ?? 'Channel';
          final playlists = ch['playlists'];
          if (playlists is List) {
            for (final pl in playlists) {
              if (pl is Map<String, dynamic> && pl['content'] is List) {
                for (final it in pl['content']) {
                  if (it is Map<String, dynamic>) {
                    final m = <String, dynamic>{
                      'id': it['id'],
                      'title': it['title'] ?? '',
                      'description': it['description'] ?? '',
                      'imageCropped':
                          it['imageCropped'] ?? it['imageFile'] ?? '',
                      'sourceFile': it['sourceFile'] ?? '',
                      'category': channelName,
                    };
                    out.add(ContentItem.fromJson(m, 'kids'));
                  }
                }
              }
            }
          }
        }
      }
    }
    return out;
  }

  List<ContentItem> _parseFitness(Map<String, dynamic> json) {
    final List<ContentItem> out = [];
    final videos = json['videos'];
    if (videos is List) {
      for (final v in videos) {
        if (v is Map<String, dynamic>) {
          final m = <String, dynamic>{
            'id': v['id'],
            'title': v['name'] ?? '',
            'description': v['description'] ?? '',
            'url': v['url'] ?? '',
          };
          out.add(ContentItem.fromJson(m, 'fitness'));
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Search', ar: 'بحث'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category bubbles
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _bubble(t(context, en: 'All', ar: 'الكل'), 'all'),
                  const SizedBox(width: 8),
                  _bubble(t(context, en: 'Streaming', ar: 'البث'), 'streaming'),
                  const SizedBox(width: 8),
                  _bubble(t(context, en: 'Games', ar: 'الألعاب'), 'games'),
                  const SizedBox(width: 8),
                  _bubble(t(context, en: 'Kids', ar: 'الأطفال'), 'kids'),
                  const SizedBox(width: 8),
                  _bubble(t(context, en: 'Fitness', ar: 'اللياقة'), 'fitness'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: t(context, en: 'Search...', ar: 'ابحث...'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (q) {
                _query = q;
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), _search);
              },
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(child: LoadingIndicator())
            else if (_error != null)
              Expanded(
                child: ErrorView(message: _error!, onRetry: _search),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    if (item.type == 'game') return GameCard(item: item);
                    return VideoCard(item: item);
                  },
                ),
              ),
          ],
        ),
      ),
      
    );
  }

  Widget _bubble(String label, String value) {
    final bool active = _category == value;
    return GestureDetector(
      onTap: () {
        setState(() => _category = value);
        _search();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: active ? null : const Color(0xFF23272F),
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          border: Border.all(color: const Color(0xFF2F3440)),
        ),
        child: Text(label),
      ),
    );
  }
}
