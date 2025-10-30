import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/watchlater_provider.dart';
import '../../widgets/cards/video_card.dart';
import '../../core/utils/i18n.dart';

class WatchLaterScreen extends StatelessWidget {
  const WatchLaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Watch Later', ar: 'مشاهدة لاحقاً'))),
      body: Consumer<WatchLaterProvider>(
        builder: (context, provider, _) {
          if (provider.items.isEmpty) {
            return Center(child: Text(t(context, en: 'Nothing saved for later', ar: 'لا يوجد عناصر محفوظة لوقت لاحق')));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.items.length,
            itemBuilder: (context, index) => VideoCard(item: provider.items[index]),
          );
        },
      ),
      
    );
  }
}


