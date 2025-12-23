import 'package:flutter/material.dart';

/// Helper class to ensure Arabic locale and RTL direction across the app
class LocaleHelper {
  /// Get the default Arabic locale
  static const Locale defaultLocale = Locale('ar', 'SA');

  /// Check if current locale is Arabic
  static bool isArabic(Locale? locale) {
    return locale?.languageCode == 'ar';
  }

  /// Get text direction based on locale
  static TextDirection getTextDirection(Locale? locale) {
    return isArabic(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Wrap widget with RTL direction for Arabic
  static Widget wrapWithRTL(Widget child, {Locale? locale}) {
    return Directionality(
      textDirection: getTextDirection(locale ?? defaultLocale),
      child: child,
    );
  }

  /// Ensure Arabic locale is set
  static Locale ensureArabicLocale(Locale? locale) {
    if (locale == null || !isArabic(locale)) {
      return defaultLocale;
    }
    return locale;
  }
}

