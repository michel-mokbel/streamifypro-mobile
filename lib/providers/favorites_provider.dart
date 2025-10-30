import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/content_item.dart';

class FavoritesProvider extends ChangeNotifier {
  List<ContentItem> _favorites = [];

  List<ContentItem> get favorites => _favorites;

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites') ?? '[]';
    _favorites = (json.decode(favoritesJson) as List)
        .map((e) {
          final map = e as Map<String, dynamic>;
          return ContentItem.fromJson(map, map['type']?.toString() ?? '');
        })
        .toList();
    notifyListeners();
  }

  Future<void> toggleFavorite(ContentItem item) async {
    final index = _favorites.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(item);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'favorites',
      json.encode(_favorites.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((e) => e.id == id);
  }
}


