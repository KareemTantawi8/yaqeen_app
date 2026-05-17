// ignore_for_file: camel_case_extensions

import 'package:flutter/material.dart';
import '../styles/colors/app_color.dart';
import '../styles/colors/dark_app_colors.dart';

extension ctx on BuildContext {
  //! Color
  Color get color => Theme.of(this).primaryColor;
  Color get colorAccent => Theme.of(this).colorScheme.secondary;
  //! Size
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;

  //! Navigation
  Future<dynamic> pushName(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushAndRemoveUntil(String routeName, {Object? arguments}) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  void pop() => Navigator.of(this).pop();
}

// ── Dark mode aware color helpers ────────────────────────────────────────────

extension AppColorExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Scaffold / page backgrounds
  Color get scaffoldBg =>
      isDark ? DarkColors.scaffold : const Color(0xFFF5F7F6);

  // Surface / card backgrounds
  Color get cardBg => isDark ? DarkColors.surface : Colors.white;
  Color get elevatedCardBg =>
      isDark ? DarkColors.surfaceElevated : Colors.white;

  // Navigation bar
  Color get navBarBg =>
      isDark ? DarkColors.navBar : AppColors.boldText; // boldText ≈ white

  // The mint-green accent used throughout (#EAF9F4)
  Color get lightAccent =>
      isDark ? DarkColors.lightAccent : const Color(0xFFEAF9F4);

  // Text
  Color get highText =>
      isDark ? DarkColors.textHigh : const Color(0xFF1A2221);
  Color get primaryText =>
      isDark ? DarkColors.textHigh : AppColors.titleColor;
  Color get secondaryText =>
      isDark ? DarkColors.textMedium : AppColors.thinText;
  // Brand green text (0xFF2B7669)
  Color get brandText =>
      isDark ? DarkColors.primary : const Color(0xFF2B7669);

  // Grey text equivalents
  Color get greyText300 =>
      isDark ? DarkColors.textLow : Colors.grey.shade300;
  Color get greyText400 =>
      isDark ? DarkColors.textLow : Colors.grey.shade400;
  Color get greyText500 =>
      isDark ? DarkColors.textLow : Colors.grey.shade500;
  Color get greyText600 =>
      isDark ? DarkColors.textMedium : Colors.grey.shade600;
  Color get greyText700 =>
      isDark ? DarkColors.textMedium : Colors.grey.shade700;

  // Icon colours on nav bar
  Color get navIconUnselected =>
      isDark ? DarkColors.textMedium : Colors.grey.shade700;

  // Divider
  Color get dividerColor =>
      isDark ? DarkColors.divider : Colors.grey.shade200;

  // Input fill
  Color get inputFillColor =>
      isDark ? DarkColors.inputFill : Colors.grey.shade50;

  // Hadith card cream equivalents
  Color get hadithCardBg =>
      isDark ? DarkColors.hadithCard : const Color(0xFFFBF6EC);
  Color get hadithCardDeep =>
      isDark ? DarkColors.hadithCardDeep : const Color(0xFFF3EAD3);
  Color get hadithInk =>
      isDark ? DarkColors.hadithInk : const Color(0xFF1F3D38);
}
