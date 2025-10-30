import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/content_item.dart';

class WatchLaterProvider extends ChangeNotifier {
  List<ContentItem> _items = [];

  List<ContentItem> get items => _items;

  Future<void> loadWatchLater() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('watch_later') ?? '[]';
    _items = (json.decode(jsonStr) as List)
        .map((e) {
          final map = e as Map<String, dynamic>;
          return ContentItem.fromJson(map, map['type']?.toString() ?? '');
        })
        .toList();
    notifyListeners();
  }

  Future<void> toggleWatchLater(ContentItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(item);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'watch_later',
      json.encode(_items.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  bool isWatchLater(String id) => _items.any((e) => e.id == id);
}


