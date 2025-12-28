import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'features/home/presentation/views/mespha_screen.dart';
import 'features/home/presentation/views/quran_screen.dart';
import 'features/home/presentation/views/quran_full_mushaf_screen.dart';
import 'features/home/presentation/views/surah_full_audio_screen.dart';
import 'features/home/presentation/views/adhan_full_screen.dart';
import 'features/splach/presentation/views/splach_screen.dart';

class YaqeenApp extends StatelessWidget {
  const YaqeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    // Force Arabic locale and RTL direction
    return MaterialApp(
      // Force Arabic as default locale
      locale: const Locale('ar', 'SA'), // Arabic (Saudi Arabia) for full RTL support
      supportedLocales: const [
        Locale('ar', 'SA'), // Arabic - Saudi Arabia
        Locale('ar'), // Arabic - generic
        Locale('en'), // English (fallback)
      ],
      // Localization delegates
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
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        MesphaScreen.routeName: (context) => const MesphaScreen(),
        QuranScreen.routeName: (context) => const QuranScreen(),
        QuranFullMushafScreen.routeName: (context) => const QuranFullMushafScreen(),
        SurahFullAudioScreen.routeName: (context) => const SurahFullAudioScreen(),
        AdhanFullScreen.routeName: (context) => const AdhanFullScreen(),
        // Add more routes here as needed
      },
    );
  }
}
