import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../screens/chatbot/chatbot_screen.dart';
import '../../core/utils/navigation_service.dart';

class ChatbotFab extends StatelessWidget {
  const ChatbotFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final ctx = rootNavigatorKey.currentContext ?? context;
        if (isChatbotOpen.value) {
          Navigator.of(ctx, rootNavigator: true).maybePop();
          return;
        }
        isChatbotOpen.value = true;
        await showModalBottomSheet(
          context: ctx,
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            // Leave space at the bottom/right so the FAB remains visible above the sheet
            return Padding(
              padding: const EdgeInsets.only(bottom: 88, right: 12, left: 0),
              child: DraggableScrollableSheet(
                initialChildSize: 0.95,
                minChildSize: 0.6,
                maxChildSize: 0.95,
                expand: false,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.mainBg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const ChatbotScreen(),
                  );
                },
              ),
            );
          },
        );
        isChatbotOpen.value = false;
      },
      backgroundColor: AppColors.accentPrimary,
      child: const Icon(Icons.chat_bubble_outline),
    );
  }
}


