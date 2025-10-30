import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chatbot_provider.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/chatbot_models.dart';
import 'message_bubble.dart';
import 'typing_indicator.dart';
import 'content_card_list.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatbotProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final ChatMessage message = provider.messages[index];

            switch (message.type) {
              case MessageType.user:
                return MessageBubble(
                  text: message.text,
                  isUser: true,
                );
              case MessageType.bot:
                return MessageBubble(
                  text: message.text,
                  isUser: false,
                );
              case MessageType.items:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.text.isNotEmpty)
                      MessageBubble(
                        text: message.text,
                        isUser: false,
                      ),
                    const SizedBox(height: 8),
                    ContentCardList(items: message.items ?? <ChatbotItem>[]),
                  ],
                );
              case MessageType.typing:
                return const TypingIndicator();
            }
          },
        );
      },
    );
  }
}


