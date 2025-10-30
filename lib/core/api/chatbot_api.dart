import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chatbot_models.dart';
import 'endpoints.dart';

class ChatbotApi {
  static const String _endpoint = '/api/chatbot.php';

  Future<ChatbotResponse> sendMessage(ChatbotRequest request) async {
    final Uri url = Uri.parse('${ApiEndpoints.baseUrl}$_endpoint');

    try {
      final http.Response response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final String body = response.body;

        if (body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
          throw ChatbotError(message: 'Server error');
        }

        final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

        if (json.containsKey('error')) {
          throw ChatbotError.fromJson(json);
        }

        return ChatbotResponse.fromJson(json);
      } else if (response.statusCode == 304) {
        throw ChatbotError(message: 'Cached response detected', code: 304);
      } else {
        throw ChatbotError(
          message: 'Server error: ${response.statusCode}',
          code: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ChatbotError(message: 'Network error: ${e.message}');
    } on FormatException {
      throw ChatbotError(message: 'Invalid response format');
    } catch (e) {
      if (e is ChatbotError) rethrow;
      throw ChatbotError(message: 'Unexpected error: $e');
    }
  }

  Future<bool> testConnection() async {
    try {
      final ChatbotResponse response =
          await sendMessage(ChatbotRequest(message: 'test', maxItems: 1));
      return response.items.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}


