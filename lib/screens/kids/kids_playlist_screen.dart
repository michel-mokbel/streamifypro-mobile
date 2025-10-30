import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';
import '../../core/models/content_item.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/watchlater_provider.dart';
import '../../widgets/cards/video_card.dart';
import 'kids_video_detail.dart';
import '../../core/utils/i18n.dart';

class KidsPlaylistScreen extends StatelessWidget {
  final String channelName;
  final Map<String, dynamic> playlistJson;
  const KidsPlaylistScreen({super.key, required this.channelName, required this.playlistJson});

  List<ContentItem> _parseVideos() {
    final items = <ContentItem>[];
    final content = playlistJson['content'];
    if (content is List) {
      for (final it in content) {
        if (it is Map<String, dynamic>) {
          final m = <String, dynamic>{
            'id': it['id'],
            'title': it['title'] ?? '',
            'title_ar': it['title_ar'],
            'description': it['description'] ?? '',
            'description_ar': it['description_ar'],
            'imageCropped': it['imageCropped'] ?? it['imageFile'] ?? '',
            'sourceFile': it['sourceFile'] ?? '',
            'category': channelName,
          };
          items.add(ContentItem.fromJson(m, 'kids'));
        }
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final name = t(context, en: playlistJson['name']?.toString() ?? '', ar: playlistJson['name_ar']?.toString() ?? playlistJson['name']?.toString() ?? '');
    final banner = playlistJson['bannerImage']?.toString() ?? '';
    final videos = _parseVideos();
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: banner.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: banner,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Shimmer.fromColors(
                      baseColor: AppColors.cardBg,
                      highlightColor: AppColors.cardHoverBg,
                      child: Container(height: 180, color: Colors.white),
                    ),
                  )
                : Container(height: 180, color: AppColors.cardBg),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final item = videos[index];
              final favs = context.watch<FavoritesProvider>();
              final later = context.watch<WatchLaterProvider>();
              return VideoCard(
                item: item,
                isFavorite: favs.isFavorite(item.id),
                isWatchLater: later.isWatchLater(item.id),
                onToggleFavorite: () => favs.toggleFavorite(item),
                onToggleWatchLater: () => later.toggleWatchLater(item),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KidsVideoDetailScreen(
                        playlistVideos: videos,
                        initialIndex: index,
                        playlistName: name,
                        playlistImage: playlistJson['profileImage']?.toString(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      
    );
  }
}


