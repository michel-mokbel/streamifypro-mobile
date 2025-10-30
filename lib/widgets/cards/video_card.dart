import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';
import '../../core/models/content_item.dart';
import '../../core/utils/stats_generator.dart';
import '../../core/utils/i18n.dart';

class VideoCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onToggleWatchLater;
  final bool isFavorite;
  final bool isWatchLater;

  const VideoCard({
    super.key,
    required this.item,
    this.onTap,
    this.onToggleFavorite,
    this.onToggleWatchLater,
    this.isFavorite = false,
    this.isWatchLater = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.thumbnail.isNotEmpty &&
                      (item.thumbnail.startsWith('http://') || item.thumbnail.startsWith('https://')))
                    CachedNetworkImage(
                      imageUrl: item.thumbnail,
                      fit: BoxFit.fill,
                      
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.cardBg,
                        highlightColor: AppColors.cardHoverBg,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(color: AppColors.cardBg),
                    )
                  else
                    Container(
                      color: AppColors.cardBg,
                      child: const Icon(Icons.play_circle_fill, size: 48, color: AppColors.textMuted),
                    ),
                  if (item.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(t(context, en: 'Premium', ar: 'مميز'), style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      localizedTitle(context, item),
                      style: AppTypography.heading2.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizedDescription(context, item),
                      style: AppTypography.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility, size: 14, color: AppColors.accentPrimary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${StatsGenerator.formatCompactInt(StatsGenerator.views('${item.type}:${item.id}'))} ' + t(context, en: 'views', ar: 'مشاهدات'),
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(children: [
                    IconButton(
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: isFavorite ? AppColors.accentDanger : AppColors.textSecondary,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                      splashRadius: 18,
                      onPressed: onToggleFavorite,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(isWatchLater ? Icons.watch_later : Icons.watch_later_outlined),
                      color: isWatchLater ? AppColors.accentPrimary : AppColors.textSecondary,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                      splashRadius: 18,
                      onPressed: onToggleWatchLater,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


