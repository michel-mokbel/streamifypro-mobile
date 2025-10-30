import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chatbot_provider.dart';
import '../../../config/theme.dart';
import '../../../core/utils/i18n.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatbotProvider>().sendMessage(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: t(context, en: 'Ask for suggestions...', ar: 'اطلب اقتراحات...'),
                hintStyle: AppTypography.bodyText.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.mainBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.accentPrimary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              style: AppTypography.bodyText,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatbotProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isTyping ? null : _sendMessage,
                icon: Icon(
                  Icons.send,
                  color: provider.isTyping ? AppColors.textMuted : AppColors.accentPrimary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardBg,
                  padding: const EdgeInsets.all(12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


