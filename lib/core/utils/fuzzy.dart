class Fuzzy {
  static String _norm(String s) => s.toLowerCase();

  // Simple Dice coefficient on bigrams
  static double score(String query, String target) {
    final a = _bigrams(_norm(query));
    final b = _bigrams(_norm(target));
    if (a.isEmpty || b.isEmpty) return 0;
    int matches = 0;
    final setB = <String, int>{};
    for (final bg in b) {
      setB[bg] = (setB[bg] ?? 0) + 1;
    }
    for (final bg in a) {
      final c = setB[bg] ?? 0;
      if (c > 0) {
        matches++;
        setB[bg] = c - 1;
      }
    }
    return (2.0 * matches) / (a.length + b.length);
  }

  static List<String> _bigrams(String s) {
    final out = <String>[];
    for (int i = 0; i < s.length - 1; i++) {
      out.add(s.substring(i, i + 2));
    }
    return out;
  }
}


