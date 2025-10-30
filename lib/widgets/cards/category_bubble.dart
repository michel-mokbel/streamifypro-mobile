import 'package:flutter/material.dart';

import '../../config/theme.dart';

class CategoryBubble extends StatelessWidget {
  final String name;
  final String? iconUrl;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryBubble({
    super.key,
    required this.name,
    this.iconUrl,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : AppColors.cardBg,
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconUrl != null && iconUrl!.isNotEmpty)
              CircleAvatar(radius: 12, backgroundImage: NetworkImage(iconUrl!)),
            if (iconUrl != null && iconUrl!.isNotEmpty) const SizedBox(width: 8),
            Text(name, style: AppTypography.bodyText),
          ],
        ),
      ),
    );
  }
}


