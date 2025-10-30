
class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  CacheEntry(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class ApiCache {
  static final Map<String, CacheEntry> _cache = {};

  static Future<T> getCachedData<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }

    final data = await fetcher();
    _cache[key] = CacheEntry(data, DateTime.now().add(ttl));
    return data;
  }

  static void clearKey(String key) => _cache.remove(key);
  static void clearAll() => _cache.clear();
}


