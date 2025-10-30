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

class FitnessDetailScreen extends StatefulWidget {
  final List<ContentItem> videos; // same category list
  final int initialIndex;
  const FitnessDetailScreen({super.key, required this.videos, required this.initialIndex});

  @override
  State<FitnessDetailScreen> createState() => _FitnessDetailScreenState();
}

class _FitnessDetailScreenState extends State<FitnessDetailScreen> {
  late int _index;
  VideoPlayerController? _controller;
  ChewieController? _chewie;

  ContentItem get _video => widget.videos[_index];

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

  void _goPrev() { if (_index > 0) { setState(() => _index--); _initPlayer(); } }
  void _goNext() { if (_index < widget.videos.length - 1) { setState(() => _index++); _initPlayer(); } }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final later = context.watch<WatchLaterProvider>();
    final others = [for (int i=0;i<widget.videos.length;i++) if (i!=_index) widget.videos[i]].take(6).toList();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final tips = (_video.metadata[isArabic ? 'tips_ar' : 'tips'] ?? _video.metadata['tips'] ?? '') as String?;
    final setsReps = (_video.metadata[isArabic ? 'sets_reps_ar' : 'sets_reps'] ?? _video.metadata['sets_reps'] ?? '') as String?;

    return Scaffold(
      appBar: AppBar(title: Text(localizedTitle(context, _video))),
      backgroundColor: AppColors.mainBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 12),
            _SectionCard(title: t(context, en: 'Description', ar: 'الوصف'), child: Text(localizedDescription(context, _video), style: AppTypography.bodyText)),
            const SizedBox(height: 12),
            if (tips != null && tips.isNotEmpty)
              _SectionCard(title: t(context, en: 'Tips', ar: 'نصائح'), icon: Icons.lightbulb, child: Text(tips, style: AppTypography.bodyText)),
            if (tips != null && tips.isNotEmpty) const SizedBox(height: 12),
            if (setsReps != null && setsReps.isNotEmpty)
              _SectionCard(title: t(context, en: 'Sets & Reps', ar: 'المجموعات والتكرارات'), icon: Icons.autorenew, child: Text(setsReps, style: AppTypography.bodyText)),

            const SizedBox(height: 16),
            Row(children: [
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
            ]),

            const SizedBox(height: 16),
            Text(t(context, en: 'More videos', ar: 'المزيد من الفيديوهات'), style: AppTypography.heading2),
            const SizedBox(height: 8),
            ...others.map((v) => _MoreItem(video: v, onTap: () {
              final idx = widget.videos.indexWhere((e) => e.id == v.id);
              if (idx >= 0) { setState(() => _index = idx); _initPlayer(); }
            })),
          ],
        ),
      ),
      
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  const _SectionCard({required this.title, required this.child, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (icon != null) Icon(icon, color: AppColors.textMuted),
            if (icon != null) const SizedBox(width: 8),
            Text(title, style: AppTypography.heading2),
          ]),
          const SizedBox(height: 8),
          child,
        ],
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
            Expanded(child: Text(localizedTitle(context, video), style: AppTypography.bodyText, maxLines: 2, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}


