import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chatbot_provider.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/suggestion_chips.dart';
import '../../core/utils/i18n.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, en: 'Assistant', ar: 'المساعد')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatbotProvider>().clearChat();
            },
            tooltip: t(context, en: 'Clear chat', ar: 'مسح المحادثة'),
          ),
        ],
      ),
      body: Column(
        children: const [
          SuggestionChips(),
          Divider(height: 1),
          Expanded(child: ChatMessageList()),
          Divider(height: 1),
          ChatInputBar(),
        ],
      ),
    );
  }
}


