import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaqeen_app/core/style/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.primary,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.textWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textWhite,
          fontSize: 16,
        ),
      ),
    );
  }
}

