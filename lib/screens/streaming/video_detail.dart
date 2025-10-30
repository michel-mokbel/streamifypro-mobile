import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/theme.dart';
import '../../core/models/content_item.dart';
import '../../core/utils/stats_generator.dart';
import '../../core/utils/i18n.dart';

class VideoDetailScreen extends StatefulWidget {
  final ContentItem video;
  final List<ContentItem>? playlistVideos;
  final int? initialIndex;
  final String? categoryName;

  const VideoDetailScreen({super.key, required this.video, this.playlistVideos, this.initialIndex, this.categoryName});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late int _index;
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  String? _initError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex ?? 0;
    _init();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _init() async {
    try {
      String? url = await _resolveStreamingUrl();
      if (url == null) {
        setState(() {
          _initError = 'Video URL unavailable';
          _loading = false;
        });
        return;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        setState(() {
          _initError = 'Invalid video URL';
          _loading = false;
        });
        return;
      }
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.accentPrimary,
          handleColor: AppColors.accentSecondary,
        ),
      );
      if (mounted) setState(() { _loading = false; });
    } catch (e) {
      setState(() { _initError = 'Failed to load video'; _loading = false; });
    }
  }

  Future<String?> _resolveStreamingUrl() async {
    // If the provided URL is already valid, use it
    final direct = widget.video.url;
    final parsed = Uri.tryParse(direct);
    if (parsed != null && (parsed.scheme == 'http' || parsed.scheme == 'https')) {
      return direct;
    }

    // Try to fetch from backend using the video ID
    final idStr = widget.video.id;
    if (idStr.isEmpty) return null;
    try {
      final resp = await http.get(Uri.parse('https://apiv2.mobileartsme.com/av_geturl?videoId=$idStr'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final error = data['error'];
        final result = data['result'];
        if ((error == 0 || error == '0') && result is String && result.isNotEmpty) {
          return result;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = widget.video.thumbnail;
    final thumbIsHttp = Uri.tryParse(thumb)?.hasScheme == true;
    final current = widget.playlistVideos != null && widget.playlistVideos!.isNotEmpty
        ? widget.playlistVideos![_index]
        : widget.video;
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(title: Text(localizedTitle(context, current))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : (thumbIsHttp
                      ? Image.network(thumb, fit: BoxFit.cover)
                      : Container(color: Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Previous / Next row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: (_index > 0 && (widget.playlistVideos?.isNotEmpty ?? false))
                            ? () { setState(() { _index--; }); _init(); }
                            : null,
                        icon: const Icon(Icons.keyboard_double_arrow_left),
                        label: Text(t(context, en: 'Previous', ar: 'السابق')),
                      ),
                      TextButton.icon(
                        onPressed: ((widget.playlistVideos?.isNotEmpty ?? false) && _index < (widget.playlistVideos!.length - 1))
                            ? () { setState(() { _index++; }); _init(); }
                            : null,
                        icon: const Icon(Icons.keyboard_double_arrow_right),
                        label: Text(t(context, en: 'Next', ar: 'التالي')),
                      ),
                    ],
                  ),

                  Text(localizedTitle(context, current), style: AppTypography.heading1),
                  const SizedBox(height: 8),

                  // Labels row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(t(context, en: 'Duration', ar: 'المدة'), style: AppTypography.caption)),
                      Expanded(child: Text(t(context, en: 'Rating', ar: 'التقييم'), style: AppTypography.caption)),
                      Expanded(child: Text(t(context, en: 'Views', ar: 'المشاهدات'), style: AppTypography.caption)),
                      Expanded(child: Text(t(context, en: 'Actions', ar: 'الإجراءات'), style: AppTypography.caption)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Values row
                  Row(
                    children: [
                      Expanded(child: Row(children: [const Icon(Icons.timer, size: 18, color: AppColors.textMuted), const SizedBox(width: 6), Text(_formatDuration(current.duration), style: AppTypography.bodyText)])),
                      Expanded(child: Row(children: [const Icon(Icons.star, size: 18, color: AppColors.textMuted), const SizedBox(width: 6), Text('${StatsGenerator.rating('streaming:${current.id}')} / 5', style: AppTypography.bodyText)])),
                      Expanded(child: Row(children: [const Icon(Icons.visibility, size: 18, color: AppColors.textMuted), const SizedBox(width: 6), Text(StatsGenerator.formatCompactInt(StatsGenerator.views('streaming:${current.id}')), style: AppTypography.bodyText)])),
                      Expanded(
                        child: Row(children: [
                          _ActionPill(icon: Icons.favorite_border, onTap: () {}),
                          const SizedBox(width: 8),
                          _ActionPill(icon: Icons.watch_later_outlined, onTap: () {}),
                        ]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Text(localizedDescription(context, current), style: AppTypography.bodyText),
                  if (_loading && _chewieController == null) ...[
                    const SizedBox(height: 12),
                    const CircularProgressIndicator(),
                  ] else if (_initError != null && _chewieController == null) ...[
                    const SizedBox(height: 12),
                    Text(_initError!, style: AppTypography.caption),
                  ],

                  const SizedBox(height: 16),
                  if (widget.categoryName != null) _CategoryCard(name: localizedCategory(context, current),  count: widget.playlistVideos?.length ?? 0),
                  const SizedBox(height: 16),
                  if (widget.playlistVideos != null && widget.playlistVideos!.length > 1) ...[
                    Text(t(context, en: 'More Videos', ar: 'المزيد من الفيديوهات') + ' ${widget.categoryName ?? ''}', style: AppTypography.heading2),
                    const SizedBox(height: 8),
                    ...widget.playlistVideos!
                        .asMap()
                        .entries
                        .where((e) => e.key != _index)
                        .take(6)
                        .map((e) => _MoreItem(
                              video: e.value,
                              onTap: () {
                                setState(() => _index = e.key);
                                _init();
                              },
                            )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }

  String _formatDuration(String raw) {
    final secs = int.tryParse(raw) ?? 0;
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

}

// Stat widget removed (inlined design)

class _CategoryCard extends StatelessWidget {
  final String name;  final int count;
  const _CategoryCard({required this.name, required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
      padding: const EdgeInsets.all(16),
      child: Row(children: [

        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: AppTypography.heading2),
            const SizedBox(height: 4),
            Text('$count videos', style: AppTypography.caption),
          ]),
        ),
      ]),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final ContentItem video; final VoidCallback onTap; const _MoreItem({required this.video, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
        child: Row(children: [
          ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)), child: Image.network(video.thumbnail, width: 120, height: 80, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(child: Text(localizedTitle(context, video), style: AppTypography.bodyText, maxLines: 2, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8), const Icon(Icons.chevron_right, color: AppColors.textMuted), const SizedBox(width: 8),
        ]),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; const _ActionPill({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.cardHoverBg, shape: BoxShape.circle, border: Border.all(color: AppColors.borderColor)),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}


