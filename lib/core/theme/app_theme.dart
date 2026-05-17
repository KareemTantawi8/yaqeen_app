import 'package:flutter/material.dart';
import '../styles/colors/app_color.dart';
import '../styles/colors/dark_app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.primaryColor,
        surface: Colors.white,
        error: AppColors.errorColor,
      ),
      cardColor: Colors.white,
      dividerColor: Color(0xFFE0E0E0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryColor),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: DarkColors.primary,
      scaffoldBackgroundColor: DarkColors.scaffold,
      colorScheme: const ColorScheme.dark(
        primary: DarkColors.primary,
        secondary: DarkColors.primary,
        surface: DarkColors.surface,
        error: DarkColors.error,
      ),
      cardColor: DarkColors.surface,
      dividerColor: DarkColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.navBar,
        foregroundColor: DarkColors.textHigh,
        elevation: 0,
        iconTheme: IconThemeData(color: DarkColors.primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.navBar,
        selectedItemColor: DarkColors.primary,
        unselectedItemColor: DarkColors.textMedium,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: DarkColors.surfaceElevated,
        contentTextStyle: TextStyle(color: DarkColors.textHigh),
      ),
    );
  }
}
