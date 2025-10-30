import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/watchlater_provider.dart';
import 'screens/auth/login_screen.dart';
import 'core/utils/navigation_service.dart';
import 'widgets/common/chatbot_fab.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..loadFavorites()),
        ChangeNotifierProvider(create: (_) => WatchLaterProvider()..loadWatchLater()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, language, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Streamify Pro',
            theme: darkTheme(),
            navigatorKey: rootNavigatorKey,
            locale: language.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final isArabic = Localizations.localeOf(context).languageCode == 'ar';
              final Widget base = child ?? const SizedBox.shrink();

              // Sync chatbot greetings with current language
              try {
                final chat = Provider.of<ChatbotProvider>(context, listen: false);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  chat.setLanguage(Provider.of<LanguageProvider>(context, listen: false).locale.languageCode);
                });
              } catch (_) {}
              final auth = Provider.of<AuthProvider>(context);
              final bool showFab = auth.isAuthenticated;
              return Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Stack(
                  children: [
                    base,
                    if (showFab)
                      const Positioned(
                        right: 16,
                        bottom: 16,
                        child: ChatbotFab(),
                      ),
                  ],
                ),
              );
            },
            onGenerateRoute: AppRoutes.onGenerateRoute,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}


