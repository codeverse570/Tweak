import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'DMSans',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          surface: AppColors.surface,
        ),
      );
}