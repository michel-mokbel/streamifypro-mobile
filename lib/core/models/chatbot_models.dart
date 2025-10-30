class ChatbotRequest {
  final String message;
  final int maxItems;
  final int? seed;
  final bool debug;

  ChatbotRequest({
    required this.message,
    this.maxItems = 8,
    this.seed,
    this.debug = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'max_items': maxItems,
      if (seed != null) 'seed': seed,
      'debug': debug,
    };
  }
}

class ChatbotResponse {
  final String summary;
  final String resultType;
  final List<ChatbotItem> items;
  final ChatbotDebugInfo? debug;

  ChatbotResponse({
    required this.summary,
    required this.resultType,
    required this.items,
    this.debug,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      summary: json['summary'] as String? ?? 'Here are some suggestions.',
      resultType: json['result_type'] as String? ?? 'suggestions',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ChatbotItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      debug: json['debug'] != null
          ? ChatbotDebugInfo.fromJson(json['debug'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ChatbotItem {
  final String id;
  final String title;
  final String type; // "video" or "game"
  final String source; // kids, games, fitness, streaming
  final int ageMin;
  final int ageMax;
  final int durationSec;
  final String thumbnail;
  final String? category;
  final String detailUrl;
  final String? channelId;
  final String? playlistId;

  ChatbotItem({
    required this.id,
    required this.title,
    required this.type,
    required this.source,
    required this.ageMin,
    required this.ageMax,
    required this.durationSec,
    required this.thumbnail,
    this.category,
    required this.detailUrl,
    this.channelId,
    this.playlistId,
  });

  factory ChatbotItem.fromJson(Map<String, dynamic> json) {
    return ChatbotItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      type: json['type'] as String? ?? 'video',
      source: json['source'] as String? ?? '',
      ageMin: json['age_min'] as int? ?? 0,
      ageMax: json['age_max'] as int? ?? 12,
      durationSec: json['duration_sec'] as int? ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      category: json['category'] as String?,
      detailUrl: json['detail_url'] as String? ?? '',
      channelId: json['channel_id'] as String?,
      playlistId: json['playlist_id'] as String?,
    );
  }

  String getFormattedDuration() {
    if (durationSec == 0) return '';

    final int hours = durationSec ~/ 3600;
    final int minutes = (durationSec % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${durationSec}s';
    }
  }

  String getAgeRange() {
    return '$ageMin-$ageMax years';
  }
}

class ChatbotDebugInfo {
  final RouterDebug? router;
  final int? totalTimeMs;

  ChatbotDebugInfo({this.router, this.totalTimeMs});

  factory ChatbotDebugInfo.fromJson(Map<String, dynamic> json) {
    return ChatbotDebugInfo(
      router: json['router'] != null
          ? RouterDebug.fromJson(json['router'] as Map<String, dynamic>)
          : null,
      totalTimeMs: json['total_time_ms'] as int?,
    );
  }
}

class RouterDebug {
  final List<String> categories;
  final String primary;
  final String method; // ai | keyword
  final int timeMs;

  RouterDebug({
    required this.categories,
    required this.primary,
    required this.method,
    required this.timeMs,
  });

  factory RouterDebug.fromJson(Map<String, dynamic> json) {
    return RouterDebug(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      primary: json['primary'] as String? ?? '',
      method: json['method'] as String? ?? 'unknown',
      timeMs: json['time_ms'] as int? ?? 0,
    );
  }
}

class ChatbotError implements Exception {
  final String message;
  final int? code;

  ChatbotError({required this.message, this.code});

  factory ChatbotError.fromJson(Map<String, dynamic> json) {
    return ChatbotError(
      message: json['error'] as String? ?? 'Unknown error',
      code: json['code'] as int?,
    );
  }

  @override
  String toString() => message;
}


