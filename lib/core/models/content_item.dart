class ContentItem {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String url;
  final String duration;
  final int views;
  final double rating;
  final bool isPremium;
  final String category;
  final String type; // 'streaming', 'game', 'kids', 'fitness'
  final Map<String, dynamic> metadata;

  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.url,
    required this.duration,
    required this.views,
    required this.rating,
    required this.isPremium,
    required this.category,
    required this.type,
    this.metadata = const {},
  });

  factory ContentItem.fromJson(Map<String, dynamic> json, String type) {
    // Prefer large thumbnail for games per requirement
    final thumbnail = type == 'game'
        ? (json['Thumbnail_Large'] ?? json['Thumbnail'] ?? json['imageCropped'] ?? '')
        : (json['Thumbnail'] ?? json['Thumbnail_Large'] ?? json['imageCropped'] ?? '');

    // Derive category for games if not provided by parser
    String derivedCategory = (json['category'] ?? '').toString();
    if (derivedCategory.isEmpty && type == 'game') {
      final catArray = json['Category'];
      if (catArray is List && catArray.isNotEmpty) {
        derivedCategory = catArray.first.toString();
      }
    }

    // Collect additional metadata if present
    final Map<String, dynamic> extras = {};
    for (final key in [
      'tips', 'tips_ar', 'sets_reps', 'sets_reps_ar',
      'category_en', 'category_ar', 'title_ar', 'description_ar',
      'imageFile', 'imageCropped', 'Package_id'
    ]) {
      if (json.containsKey(key)) extras[key] = json[key];
    }

    return ContentItem(
      id: (json['ID'] ?? json['Id'] ?? json['id'] ?? '').toString(),
      title: (json['Title'] ?? json['title'] ?? 'Untitled').toString(),
      description: (json['Description'] ?? json['description'] ?? '').toString(),
      thumbnail: thumbnail.toString(),
      url: (json['Content'] ?? json['url'] ?? json['sourceFile'] ?? '').toString(),
      duration: (json['Duration'] ?? json['duration'] ?? '').toString(),
      views: int.tryParse((json['ViewCount'] ?? '0').toString()) ?? 0,
      rating: double.tryParse((json['avrate'] ?? '0').toString()) ?? 0,
      isPremium: (json['isPremium'] == 'True') || (json['isPremium'] == true),
      category: derivedCategory,
      type: type,
      metadata: extras,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'url': url,
      'duration': duration,
      'views': views,
      'rating': rating,
      'isPremium': isPremium,
      'category': category,
      'type': type,
      'metadata': metadata,
    };
  }
}


