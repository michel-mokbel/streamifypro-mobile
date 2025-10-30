import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../config/theme.dart';
import '../../core/models/content_item.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/watchlater_provider.dart';
import '../../core/utils/i18n.dart';

class KidsVideoDetailScreen extends StatefulWidget {
  final List<ContentItem> playlistVideos;
  final int initialIndex;
  final String playlistName;
  final String? playlistImage;

  const KidsVideoDetailScreen({
    super.key,
    required this.playlistVideos,
    required this.initialIndex,
    required this.playlistName,
    this.playlistImage,
  });

  @override
  State<KidsVideoDetailScreen> createState() => _KidsVideoDetailScreenState();
}

class _KidsVideoDetailScreenState extends State<KidsVideoDetailScreen> {
  late int _index;
  VideoPlayerController? _controller;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _initPlayer();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  ContentItem get _video => widget.playlistVideos[_index];

  Future<void> _initPlayer() async {
    _disposePlayer();
    _controller = VideoPlayerController.networkUrl(Uri.parse(_video.url));
    await _controller!.initialize();
    _chewie = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.accentPrimary,
        handleColor: AppColors.accentSecondary,
      ),
    );
    if (mounted) setState(() {});
  }

  void _disposePlayer() {
    _chewie?.dispose();
    _controller?.dispose();
  }

  @override
  void dispose() {
    _disposePlayer();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _goPrev() {
    if (_index > 0) {
      setState(() => _index--);
      _initPlayer();
    }
  }

  void _goNext() {
    if (_index < widget.playlistVideos.length - 1) {
      setState(() => _index++);
      _initPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final later = context.watch<WatchLaterProvider>();
    final others = widget.playlistVideos
        .asMap()
        .entries
        .where((e) => e.key != _index)
        .map((e) => e.value)
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(localizedTitle(context, _video))),
      backgroundColor: AppColors.mainBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _chewie == null ? const Center(child: CircularProgressIndicator()) : Chewie(controller: _chewie!),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(onPressed: _goPrev, icon: const Icon(Icons.keyboard_double_arrow_left), label: Text(t(context, en: 'Previous', ar: 'السابق'))),
                TextButton.icon(onPressed: _goNext, icon: const Icon(Icons.keyboard_double_arrow_right), label: Text(t(context, en: 'Next', ar: 'التالي'))),
              ],
            ),
            const SizedBox(height: 8),
            Text(localizedTitle(context, _video), style: AppTypography.heading1),
            const SizedBox(height: 8),
            Text(localizedDescription(context, _video), style: AppTypography.bodyText),
            const SizedBox(height: 16),
            // Actions
            Row(
              children: [
                IconButton(
                  icon: Icon(favs.isFavorite(_video.id) ? Icons.favorite : Icons.favorite_border),
                  color: favs.isFavorite(_video.id) ? AppColors.accentDanger : AppColors.textSecondary,
                  onPressed: () => favs.toggleFavorite(_video),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(later.isWatchLater(_video.id) ? Icons.watch_later : Icons.watch_later_outlined),
                  color: later.isWatchLater(_video.id) ? AppColors.accentPrimary : AppColors.textSecondary,
                  onPressed: () => later.toggleWatchLater(_video),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Playlist summary
            Text(t(context, en: 'Playlist', ar: 'قائمة التشغيل'), style: AppTypography.heading2),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (widget.playlistImage != null && widget.playlistImage!.isNotEmpty)
                        ? Image.network(widget.playlistImage!, width: 56, height: 56, fit: BoxFit.cover)
                        : Container(width: 56, height: 56, color: AppColors.cardHoverBg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.playlistName, style: AppTypography.heading2),
                        const SizedBox(height: 4),
                        Text('${widget.playlistVideos.length} ${t(context, en: 'videos', ar: 'فيديو')}', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // More from playlist
            Text(t(context, en: 'More from this playlist', ar: 'المزيد من هذه القائمة'), style: AppTypography.heading2),
            const SizedBox(height: 8),
            ...others.map((it) => _MoreItem(video: it, onTap: () {
                  final newIndex = widget.playlistVideos.indexWhere((v) => v.id == it.id);
                  if (newIndex >= 0) {
                    setState(() => _index = newIndex);
                    _initPlayer();
                  }
                })),
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final ContentItem video;
  final VoidCallback onTap;
  const _MoreItem({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: (video.thumbnail.isNotEmpty)
                  ? Image.network(video.thumbnail, width: 120, height: 80, fit: BoxFit.cover)
                  : Container(width: 120, height: 80, color: AppColors.cardHoverBg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(localizedTitle(context, video), style: AppTypography.bodyText, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}


