import 'dart:math';

class StatsGenerator {
  static int _hash(String s) {
    int h = 0;
    for (int i = 0; i < s.length; i++) {
      h = 0x1fffffff & (h + s.codeUnitAt(i));
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h & 0x7fffffff;
  }

  static final Map<String, Random> _rngCache = {};

  static Random _rng(String key) {
    return _rngCache.putIfAbsent(key, () => Random(_hash(key)));
  }

  static int views(String key, {int min = 50000, int max = 2500000}) {
    final r = _rng('views:$key');
    return min + r.nextInt(max - min);
  }

  static int plays(String key, {int min = 10000, int max = 2000000}) {
    final r = _rng('plays:$key');
    return min + r.nextInt(max - min);
  }

  static double rating(String key, {double min = 3.0, double max = 4.9}) {
    final r = _rng('rating:$key');
    return double.parse((min + r.nextDouble() * (max - min)).toStringAsFixed(1));
  }

  static String formatCompactInt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  static String durationHuman(String durationOrSeconds) {
    final secs = int.tryParse(durationOrSeconds) ?? 0;
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}


