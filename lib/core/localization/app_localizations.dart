import 'package:flutter/material.dart';

/// App Localizations class to manage all app strings
/// Currently supports Arabic as default language
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common strings
  static const Map<String, String> _localizedValues = {
    'app_name': 'تطبيق يقين',
    'loading': 'جاري التحميل...',
    'error': 'حدث خطأ',
    'retry': 'إعادة المحاولة',
    'no_data': 'لا توجد بيانات',
    'cancel': 'إلغاء',
    'ok': 'موافق',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'search': 'بحث',
    'settings': 'الإعدادات',
    'home': 'الرئيسية',
    'books': 'الكتب',
    'quran': 'القرآن',
    'azkar': 'الأذكار',
    'prayer': 'الصلاة',
    'events': 'الأحداث',
    'allah_names': 'أسماء الله الحسنى',
  };

  String translate(String key) {
    return _localizedValues[key] ?? key;
  }

  // Getters for common strings
  String get appName => translate('app_name');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get noData => translate('no_data');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get settings => translate('settings');
  String get home => translate('home');
  String get books => translate('books');
  String get quran => translate('quran');
  String get azkar => translate('azkar');
  String get prayer => translate('prayer');
  String get events => translate('events');
  String get allahNames => translate('allah_names');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

