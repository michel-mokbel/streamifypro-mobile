import 'package:flutter/material.dart';

import '../../config/theme.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({super.key, required String titleText})
      : super(
          title: Text(titleText, style: AppTypography.heading2),
          backgroundColor: AppColors.sidebarBg,
          elevation: 0,
        );
}


