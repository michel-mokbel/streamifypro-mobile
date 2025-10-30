import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/streaming/streaming_screen.dart';
import '../screens/games/games_screen.dart';
import '../screens/kids/kids_channels_screen.dart';
import '../screens/fitness/fitness_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/legal/terms_screen.dart';
import '../screens/legal/privacy_policy_screen.dart';

class AppRoutes {
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String home = '/home';
  static const String streaming = '/streaming';
  static const String games = '/games';
  static const String kids = '/kids';
  static const String fitness = '/fitness';
  static const String search = '/search';
  static const String chatbot = '/chatbot';
  static const String terms = '/legal/terms';
  static const String privacy = '/legal/privacy';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case streaming:
        return MaterialPageRoute(builder: (_) => const StreamingScreen());
      case games:
        return MaterialPageRoute(builder: (_) => const GamesScreen());
      case kids:
        return MaterialPageRoute(builder: (_) => const KidsChannelsScreen());
      case fitness:
        return MaterialPageRoute(builder: (_) => const FitnessScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case chatbot:
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case login:
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}


