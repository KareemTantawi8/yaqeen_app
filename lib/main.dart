import 'package:audio_session/audio_session.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaqeen_app/core/services/prayer_notification_service.dart';
import 'package:yaqeen_app/core/services/service_locator.dart';
import 'package:yaqeen_app/yaqeen_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

  // Configure the audio session for music so all just_audio players get
  // correct audio focus on both iOS and Android.
  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  } catch (e) {
    debugPrint('AudioSession.configure failed: $e');
  }

  final clarityConfig = ClarityConfig(
    projectId: 'scpt8xziyk',
    logLevel: kReleaseMode ? LogLevel.None : LogLevel.Error,
  );

  runApp(
    ClarityWidget(
      app: const ProviderScope(child: YaqeenApp()),
      clarityConfig: clarityConfig,
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await PrayerNotificationService.initialize();
      await PrayerNotificationService.handleAppLaunchFromNotification();
    } catch (e) {
      debugPrint('PrayerNotificationService bootstrap failed: $e');
    }
  });
}
