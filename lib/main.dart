import 'package:audio_session/audio_session.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:yaqeen_app/core/services/prayer_notification_service.dart';
import 'package:yaqeen_app/core/services/service_locator.dart';
import 'package:yaqeen_app/yaqeen_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background audio for Quran & Adhan (must be first).
  // audio_service asserts: if the notification is ongoing, the foreground service
  // MUST stop on pause — otherwise the OS would never let the notification be dismissed.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yaqeen.audio',
    androidNotificationChannelName: 'يقين — القرآن والأذان',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // iOS/Android: declare media playback so the OS allows audio in background until the process stops.
  final audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration.music());

  // Prayer-time notifications (timezone init happens inside)
  await PrayerNotificationService.initialize();

  // Dependency injection
  await setupServiceLocator();

  // Navigate to adhan screen if the app was opened by tapping a notification
  await PrayerNotificationService.handleAppLaunchFromNotification();

  final config = ClarityConfig(
    projectId: 'scpt8xziyk',
    logLevel: LogLevel.Verbose,
  );

  runApp(
    ClarityWidget(
      app: ProviderScope(child: YaqeenApp()),
      clarityConfig: config,
    ),
  );
}
