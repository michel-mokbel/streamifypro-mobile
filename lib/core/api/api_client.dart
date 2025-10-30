import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:streamifypro/core/api/endpoints.dart';

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.login()),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed (${response.statusCode})');
  }

  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.signup()),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Signup failed (${response.statusCode})');
  }

  Future<void> logout() async {
    try {
      await _client.post(Uri.parse(ApiEndpoints.logout()));
    } catch (_) {
      // ignore network errors on logout
    }
  }

  Future<Map<String, dynamic>> fetchRoute(String route, String lang) async {
    late final String url;
    switch (route) {
      case 'streaming':
        url = ApiEndpoints.streaming(lang);
        break;
      case 'games':
        url = ApiEndpoints.games(lang);
        break;
      case 'kids':
        url = ApiEndpoints.kids(lang);
        break;
      case 'fitness':
        url = ApiEndpoints.fitness(lang);
        break;
      default:
        throw ArgumentError('Unsupported route $route');
    }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Fetch failed (${response.statusCode})');
  }

  void dispose() {
    _client.close();
  }
}


