import 'package:flutter/foundation.dart';

import '../core/api/chatbot_api.dart';
import '../core/models/chatbot_models.dart';
import '../core/models/chat_message.dart';

class ChatbotProvider extends ChangeNotifier {
  final ChatbotApi _api = ChatbotApi();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  ChatbotError? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  ChatbotError? get error => _error;
  bool get hasError => _error != null;

  ChatbotProvider() {
    _initialize();
  }

  void _initialize() {
    _messages = [];
    notifyListeners();
  }

  String _lang = 'en';

  void setLanguage(String code) {
    if (_lang == code && _messages.isNotEmpty) return;
    _lang = code;
    _messages = [
      ChatMessage.bot(
        _lang == 'ar'
            ? 'مرحبًا! يمكنني اقتراح مقاطع فيديو أو ألعاب بناءً على المواضيع التي تهتم بها.'
            : 'Hi! I can suggest videos or games based on topics you\'re interested in.',
      ),
      ChatMessage.bot(
        _lang == 'ar'
            ? 'جرّب: "فيديوهات الحروف الأبجدية" أو "أريد ألعاب تفاعلية"'
            : 'Try: "Show me alphabet videos" or "I want interactive games"',
      ),
    ];
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _error = null;

    final ChatMessage userMessage = ChatMessage.user(text);
    _messages.add(userMessage);
    notifyListeners();

    _isTyping = true;
    final ChatMessage typingMessage = ChatMessage.typing();
    _messages.add(typingMessage);
    notifyListeners();

    try {
      final ChatbotRequest request = ChatbotRequest(
        message: text,
        maxItems: 8,
        debug: false,
      );

      final ChatbotResponse response = await _api.sendMessage(request);

      _messages.removeWhere((m) => m.type == MessageType.typing);
      _isTyping = false;

      if (response.items.isEmpty) {
        _messages.add(ChatMessage.bot(
          'Sorry, I couldn\'t find any content matching your request. Try asking differently!',
        ));
      } else {
        _messages.add(ChatMessage.items(response.summary, response.items));
      }

      notifyListeners();
    } on ChatbotError catch (e) {
      _error = e;
      _messages.removeWhere((m) => m.type == MessageType.typing);
      _isTyping = false;

      _messages.add(ChatMessage.bot(
        'Network error. Please try again.',
      ));

      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    _isTyping = false;
    _initialize();
    notifyListeners();
  }

  void removeTypingIndicator() {
    _messages.removeWhere((m) => m.type == MessageType.typing);
    _isTyping = false;
    notifyListeners();
  }
}


