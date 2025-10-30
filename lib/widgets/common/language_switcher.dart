import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../config/theme.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool iconOnly;
  const LanguageSwitcher({super.key, this.iconOnly = true});

  @override
  Widget build(BuildContext context) {
    final code = context.watch<LanguageProvider>().locale.languageCode;
    final isArabic = code == 'ar';
    final label = isArabic ? 'AR' : 'EN';
    final Widget child = iconOnly
        ? const Icon(Icons.language, color: AppColors.textPrimary)
        : Row(children: [const Icon(Icons.language, color: AppColors.textPrimary), const SizedBox(width: 6), Text(label)]);

    return PopupMenuButton<String>(
      icon: iconOnly ? child as Icon : null,
      tooltip: 'Language',
      color: AppColors.cardBg,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: const Text('English'),
        ),
        PopupMenuItem(
          value: 'ar',
          child: const Text('العربية'),
        ),
      ],
      onSelected: (value) {
        context.read<LanguageProvider>().setLanguage(value);
      },
      child: iconOnly ? null : child,
    );
  }
}


