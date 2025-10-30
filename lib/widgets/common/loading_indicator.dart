import 'package:flutter/material.dart';

import '../../config/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  const LoadingIndicator({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accentPrimary),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.bodyText),
        ],
      ),
    );
  }
}


