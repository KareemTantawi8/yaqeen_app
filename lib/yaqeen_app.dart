import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_localizations.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/navigator_key.dart';
import 'features/home/presentation/views/mespha_screen.dart';
import 'features/home/presentation/views/quran_screen.dart';
import 'features/home/presentation/views/quran_full_mushaf_screen.dart';
import 'features/home/presentation/views/surah_full_audio_screen.dart';
import 'features/home/presentation/views/adhan_full_screen.dart';
import 'features/home/presentation/views/bottom_nav_bar.dart';
import 'features/home/presentation/views/widgets/adhan_alert_popup.dart';
import 'features/home/presentation/views/quran_read_screen.dart';
import 'features/home/presentation/views/quran_audio_screen.dart';
import 'features/home/presentation/views/quran_tafsir_screen.dart';
import 'features/splach/presentation/views/splach_screen.dart';
import 'features/splach/presentation/views/force_update_screen.dart';
import 'features/vendor/presentation/views/vendor_dashboard_screen.dart';
import 'features/Prayer/presentation/views/adhan_settings_screen.dart';

class YaqeenApp extends ConsumerWidget {
  const YaqeenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Force Arabic locale and RTL direction
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Force RTL for Arabic across all screens
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      // Handles routes not in the static [routes] map.
      // /adhan-alert uses a custom fade transition so the popup feels immersive.
      onGenerateRoute: (settings) {
        if (settings.name == AdhanAlertPopup.routeName) {
          final args = settings.arguments as Map?;
          final prayerName = args?['prayerName'] as String? ?? '';
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, __, ___) =>
                AdhanAlertPopup(prayerName: prayerName),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          );
        }
        return null;
      },
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        ForceUpdateScreen.routeName: (context) => const ForceUpdateScreen(),
        BottomNavBar.routeName: (context) => const BottomNavBar(),
        MesphaScreen.routeName: (context) => const MesphaScreen(),
        QuranScreen.routeName: (context) => const QuranScreen(),
        QuranReadScreen.routeName: (context) => const QuranReadScreen(),
        QuranAudioScreen.routeName: (context) => const QuranAudioScreen(),
        QuranTafsirScreen.routeName: (context) => const QuranTafsirScreen(),
        QuranFullMushafScreen.routeName: (context) =>
            const QuranFullMushafScreen(),
        SurahFullAudioScreen.routeName: (context) =>
            const SurahFullAudioScreen(),
        AdhanFullScreen.routeName: (context) => const AdhanFullScreen(),
        AdhanSettingsScreen.routeName: (context) =>
            const AdhanSettingsScreen(),
        VendorDashboardScreen.routeName: (context) =>
            const VendorDashboardScreen(),
      },
    );
  }
}
