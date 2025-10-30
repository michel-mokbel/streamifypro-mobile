import 'package:flutter/material.dart';

class AppColors {
  static const Color sidebarBg = Color(0xFF0F1419);
  static const Color mainBg = Color(0xFF1A1D24);
  static const Color cardBg = Color(0xff23272f);
  static const Color cardHoverBg = Color(0xff23272f);

  static const Color textPrimary = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFFB4B8C5);
  static const Color textMuted = Color(0xFF8B92A6);

  static const Color accentPrimary = Color(0xFF6366F1);
  static const Color accentSecondary = Color(0xFF8B5CF6);
  static const Color accentSuccess = Color(0xFF10B981);
  static const Color accentWarning = Color(0xFFF59E0B);
  static const Color accentDanger = Color(0xFFEF4444);

  static const Color borderColor = Color(0xFF2F3440);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
}

class AppTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.mainBg,
    primaryColor: AppColors.accentPrimary,
    // Card theme configuration moved to component level to avoid SDK type drift.
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sidebarBg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    textTheme: const TextTheme(
      displayLarge: AppTypography.heading1,
      displayMedium: AppTypography.heading2,
      bodyLarge: AppTypography.bodyText,
      bodySmall: AppTypography.caption,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentPrimary,
      secondary: AppColors.accentSecondary,
      surface: AppColors.cardBg,
      error: AppColors.accentDanger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    useMaterial3: false,
  );
}


