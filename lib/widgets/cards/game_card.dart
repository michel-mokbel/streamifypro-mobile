import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';
import '../../core/models/content_item.dart';
import '../../core/utils/stats_generator.dart';
import '../../core/utils/i18n.dart';

class GameCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback? onTap;
  final bool isFavorite;
  final bool isWatchLater;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onToggleWatchLater;

  const GameCard({super.key, required this.item, this.onTap, this.isFavorite = false, this.isWatchLater = false, this.onToggleFavorite, this.onToggleWatchLater});

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
              child: CachedNetworkImage(
                imageUrl: item.thumbnail,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.cardBg,
                  highlightColor: AppColors.cardHoverBg,
                  child: Container(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 72),
              child: Text(
                localizedTitle(context, item),
                style: AppTypography.heading2.copyWith(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sports_esports, size: 14, color: AppColors.accentPrimary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${StatsGenerator.formatCompactInt(StatsGenerator.plays('game:${item.id}'))} ' + t(context, en: 'plays', ar: 'مرات اللعب'),
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                        color: isFavorite ? AppColors.accentDanger : AppColors.textSecondary,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                        splashRadius: 18,
                        onPressed: onToggleFavorite,
                      ),
                      IconButton(
                        icon: Icon(isWatchLater ? Icons.watch_later : Icons.watch_later_outlined),
                        color: isWatchLater ? AppColors.accentPrimary : AppColors.textSecondary,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                        splashRadius: 18,
                        onPressed: onToggleWatchLater,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
