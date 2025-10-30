import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chatbot_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../config/theme.dart';

class SuggestionChips extends StatelessWidget {
  const SuggestionChips({super.key});

  List<Map<String, String>> _getChipData(String languageCode) {
    final bool isArabic = languageCode == 'ar';

    return [
      {
        'label': isArabic ? 'حروف الأبجدية' : 'Alphabet Songs',
        'query': isArabic ? 'حروف الأبجدية' : 'Alphabet songs',
      },
      {
        'label': isArabic ? 'فيديوهات الحيوانات' : 'Animal Videos',
        'query': isArabic ? 'فيديوهات عن الحيوانات' : 'Animal videos',
      },
      {
        'label': isArabic ? 'ألعاب للأطفال' : 'Games for Kids',
        'query': isArabic ? 'ألعاب للأطفال' : 'Games for kids',
      },
      {
        'label': isArabic ? 'قصص قبل النوم' : 'Bedtime Stories',
        'query': isArabic ? 'قصص قبل النوم' : 'Bedtime stories',
      },
      {
        'label': isArabic ? 'تعلم الأرقام' : 'Learn Numbers',
        'query': isArabic ? 'تعلم الأرقام' : 'Learn numbers',
      },
      {
        'label': isArabic ? 'رقص وحركة' : 'Dance & Movement',
        'query': isArabic ? 'فيديوهات رقص' : 'Dance videos',
      },
      {
        'label': isArabic ? 'علوم للأطفال' : 'Science for Kids',
        'query': isArabic ? 'علوم للأطفال' : 'Science for kids',
      },
      {
        'label': isArabic ? 'أغاني تعليمية' : 'Educational Songs',
        'query': isArabic ? 'أغاني تعليمية' : 'Educational songs',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final String languageCode = context.watch<LanguageProvider>().locale.languageCode;
    final List<Map<String, String>> chips = _getChipData(languageCode);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: chips.length,
        itemBuilder: (context, index) {
          final Map<String, String> chip = chips[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(chip['label']!),
              backgroundColor: AppColors.cardBg,
              side: BorderSide(color: AppColors.borderColor),
              labelStyle: AppTypography.bodyText.copyWith(fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onPressed: () {
                context.read<ChatbotProvider>().sendMessage(chip['query']!);
              },
            ),
          );
        },
      ),
    );
  }
}


