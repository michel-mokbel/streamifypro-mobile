import 'chatbot_models.dart';

enum MessageType {
  user,
  bot,
  items,
  typing,
}

class ChatMessage {
  final String id;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final List<ChatbotItem>? items; // For items type messages

  ChatMessage({
    required this.id,
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.items,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      type: MessageType.user,
    );
  }

  factory ChatMessage.bot(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      type: MessageType.bot,
    );
  }

  factory ChatMessage.items(String summary, List<ChatbotItem> items) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: summary,
      type: MessageType.items,
      items: items,
    );
  }

  factory ChatMessage.typing() {
    return ChatMessage(
      id: 'typing',
      text: '',
      type: MessageType.typing,
    );
  }
}


