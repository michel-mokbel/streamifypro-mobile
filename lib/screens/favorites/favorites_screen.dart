import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';
import '../../widgets/cards/video_card.dart';
import '../../core/utils/i18n.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Favorites', ar: 'المفضلة'))),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, _) {
          if (provider.favorites.isEmpty) {
            return Center(child: Text(t(context, en: 'No favorites yet', ar: 'لا مفضلة بعد')));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) => VideoCard(item: provider.favorites[index]),
          );
        },
      ),
      
    );
  }
}


