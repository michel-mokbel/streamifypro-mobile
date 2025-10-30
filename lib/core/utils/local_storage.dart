import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  // SharedPreferences helpers
  static Future<void> setString(String key, String value) async {
    final prefs = await _prefs();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _prefs();
    return prefs.getString(key);
  }

  static Future<void> setJson(String key, Object value) async {
    await setString(key, json.encode(value));
  }

  static Future<Object?> getJson(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return json.decode(str);
  }

  // Secure storage helpers
  static Future<void> setSecure(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  static Future<String?> getSecure(String key) async {
    return _secure.read(key: key);
  }

  static Future<void> deleteSecure(String key) async {
    await _secure.delete(key: key);
  }
}


