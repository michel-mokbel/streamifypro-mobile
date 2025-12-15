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
    
    // Try to parse error message from response body
    String errorMessage;
    try {
      final errorBody = json.decode(response.body) as Map<String, dynamic>;
      if (errorBody.containsKey('error')) {
        errorMessage = errorBody['error'].toString();
      } else if (errorBody.containsKey('message')) {
        errorMessage = errorBody['message'].toString();
      } else {
        // JSON parsed but no error/message field, use status code specific messages
        errorMessage = _getLoginErrorMessage(response.statusCode);
      }
    } catch (_) {
      // If response is not JSON, use status code specific messages
      errorMessage = _getLoginErrorMessage(response.statusCode);
    }
    
    throw Exception(errorMessage);
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
    
    // Try to parse error message from response body
    String errorMessage;
    try {
      final errorBody = json.decode(response.body) as Map<String, dynamic>;
      if (errorBody.containsKey('error')) {
        errorMessage = errorBody['error'].toString();
      } else if (errorBody.containsKey('message')) {
        errorMessage = errorBody['message'].toString();
      } else {
        // JSON parsed but no error/message field, use status code specific messages
        errorMessage = _getSignupErrorMessage(response.statusCode);
      }
    } catch (_) {
      // If response is not JSON, use status code specific messages
      errorMessage = _getSignupErrorMessage(response.statusCode);
    }
    
    throw Exception(errorMessage);
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

  String _getLoginErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Invalid username or password. Please try again.';
      case 400:
        return 'Invalid input. Please check your information and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Login failed (${statusCode})';
    }
  }

  String _getSignupErrorMessage(int statusCode) {
    switch (statusCode) {
      case 409:
        return 'Username or email already exists. Please try a different one.';
      case 400:
        return 'Invalid input. Please check your information and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Signup failed (${statusCode})';
    }
  }

  void dispose() {
    _client.close();
  }
}


