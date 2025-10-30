import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';
import '../../core/api/api_cache.dart';
import '../../core/api/api_client.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/navigation/side_drawer.dart';
import 'kids_channel_screen.dart';
import '../../core/utils/i18n.dart';

class KidsChannelsScreen extends StatefulWidget {
  const KidsChannelsScreen({super.key});

  @override
  State<KidsChannelsScreen> createState() => _KidsChannelsScreenState();
}

class _KidsChannelsScreenState extends State<KidsChannelsScreen> {
  final ApiClient _api = ApiClient();
  bool _loading = true;
  String? _error;
  List<_KidsChannel> _channels = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final lang = context.read<LanguageProvider>().locale.languageCode;
      final data = await ApiCache.getCachedData<Map<String, dynamic>>(
        'kids-$lang',
        () => _api.fetchRoute('kids', lang),
      );
      setState(() => _channels = _parseChannels(data));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_KidsChannel> _parseChannels(Map<String, dynamic> json) {
    final result = <_KidsChannel>[];
    final channels = json['channels'];
    if (channels is List) {
      for (final ch in channels) {
        if (ch is Map<String, dynamic>) {
          result.add(_KidsChannel(
            id: (ch['id'] ?? '').toString(),
            name: ch['name']?.toString() ?? 'Channel',
            description: ch['description']?.toString() ?? '',
            bannerImage: ch['bannerImage']?.toString() ?? '',
            profileImage: ch['profileImage']?.toString() ?? '',
            raw: ch,
          ));
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kids')), 
      drawer: const SideDrawer(),
      body: _loading
          ? const LoadingIndicator()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _channels.length,
                  itemBuilder: (context, index) => _ChannelCard(channel: _channels[index]),
                ),
      
    );
  }
}

class _KidsChannel {
  final String id;
  final String name;
  final String description;
  final String bannerImage;
  final String profileImage;
  final Map<String, dynamic> raw; // full json for channel (contains playlists)
  _KidsChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.bannerImage,
    required this.profileImage,
    required this.raw,
  });
}

class _ChannelCard extends StatelessWidget {
  final _KidsChannel channel;
  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: (channel.bannerImage.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: channel.bannerImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Shimmer.fromColors(
                      baseColor: AppColors.cardBg,
                      highlightColor: AppColors.cardHoverBg,
                      child: Container(height: 180, color: Colors.white),
                    ),
                  )
                : Container(height: 180, color: AppColors.cardBg),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (channel.profileImage.isNotEmpty)
                      ? CachedNetworkImage(imageUrl: channel.profileImage, width: 56, height: 56, fit: BoxFit.cover)
                      : Container(width: 56, height: 56, color: AppColors.cardHoverBg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t(context, en: channel.name, ar: channel.raw['name_ar']?.toString() ?? channel.name), style: AppTypography.heading2),
                      const SizedBox(height: 8),
                      Text(t(context, en: channel.description, ar: channel.raw['description_ar']?.toString() ?? channel.description), style: AppTypography.bodyText, maxLines: 3, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KidsChannelScreen(channelJson: channel.raw),
                              ),
                            );
                          },
                          child: Text(t(context, en: 'View Channel', ar: 'عرض القناة')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


