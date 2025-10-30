import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';
import '../../widgets/navigation/side_drawer.dart';
import 'kids_playlist_screen.dart';
import '../../core/utils/i18n.dart';

class KidsChannelScreen extends StatelessWidget {
  final Map<String, dynamic> channelJson;
  const KidsChannelScreen({super.key, required this.channelJson});

  @override
  Widget build(BuildContext context) {
    final name = t(context, en: channelJson['name']?.toString() ?? '', ar: channelJson['name_ar']?.toString() ?? channelJson['name']?.toString() ?? '');
    final description = t(context, en: channelJson['description']?.toString() ?? '', ar: channelJson['description_ar']?.toString() ?? channelJson['description']?.toString() ?? '');
    final banner = channelJson['bannerImage']?.toString() ?? '';
    final profile = channelJson['profileImage']?.toString() ?? '';
    final playlists = (channelJson['playlists'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      drawer: const SideDrawer(),
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: profile.isNotEmpty
                      ? CachedNetworkImage(imageUrl: profile, width: 72, height: 72, fit: BoxFit.cover)
                      : Container(width: 72, height: 72, color: AppColors.cardHoverBg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.heading2),
                      const SizedBox(height: 8),
                      Text(description, style: AppTypography.bodyText),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...playlists.map((pl) => _PlaylistCard(channelName: name, playlist: pl)),
        ],
      ),
      
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final String channelName;
  final Map<String, dynamic> playlist;
  const _PlaylistCard({required this.channelName, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final name = t(
      context,
      en: playlist['name']?.toString() ?? 'Playlist',
      ar: playlist['name_ar']?.toString() ?? playlist['name']?.toString() ?? 'Playlist',
    );
    final profile = playlist['profileImage']?.toString() ?? '';
    final content = (playlist['content'] as List?)?.length ?? 0;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KidsPlaylistScreen(channelName: channelName, playlistJson: playlist),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: profile.isNotEmpty
                  ? CachedNetworkImage(imageUrl: profile, width: 56, height: 56, fit: BoxFit.cover)
                  : Container(width: 56, height: 56, color: AppColors.cardHoverBg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.heading2),
                  const SizedBox(height: 4),
                  Text('$content ${t(context, en: 'videos', ar: 'فيديو')}', style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}


