import 'package:flutter/widgets.dart';

import '../models/content_item.dart';

bool isArabic(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar';

String t(BuildContext context, {required String en, required String ar}) =>
    isArabic(context) ? ar : en;

String localizedTitle(BuildContext context, ContentItem item) {
  if (isArabic(context)) {
    final v = item.metadata['title_ar'];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return item.title;
}

String localizedDescription(BuildContext context, ContentItem item) {
  if (isArabic(context)) {
    final v = item.metadata['description_ar'];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return item.description;
}

String localizedCategory(BuildContext context, ContentItem item) {
  if (isArabic(context)) {
    final v = item.metadata['category_ar'];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return item.category;
}

// No-op helper; LanguageProvider already updates MaterialApp.locale


