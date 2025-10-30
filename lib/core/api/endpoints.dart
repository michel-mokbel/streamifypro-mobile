import 'package:streamifypro/config/environment.dart';

class ApiEndpoints {
  static String get baseUrl => Environment.apiBaseUrl;

  static String login() => '$baseUrl/includes/auth.php?action=login';
  static String signup() => '$baseUrl/includes/auth.php?action=signup';
  static String logout() => '$baseUrl/includes/auth.php?action=logout';

  static String streaming(String lang) => '$baseUrl/api/api.php?route=streaming&lang=$lang';
  static String games(String lang) => '$baseUrl/api/api.php?route=games&lang=$lang';
  static String kids(String lang) => '$baseUrl/api/api.php?route=kids&lang=$lang';
  static String fitness(String lang) => '$baseUrl/api/api.php?route=fitness&lang=$lang';
}


