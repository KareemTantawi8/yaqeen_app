import 'package:audio_session/audio_session.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:yaqeen_app/core/services/prayer_notification_service.dart';
import 'package:yaqeen_app/core/services/service_locator.dart';
import 'package:yaqeen_app/yaqeen_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Service locator is pure Dart — keep it synchronous so any widget that touches
  // GetIt during the first build never hits a missing registration.
  setupServiceLocator();

  // Show the splash immediately. All native plugins (audio service, notifications,
  // timezone, Clarity) are initialised in the background to keep the first frame
  // from being blocked — the splash itself waits 4s before any screen needs them.
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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _bootstrapPlatformServices();
  });
}

Future<void> _bootstrapPlatformServices() async {
  // Each step is isolated so a single plugin stalling cannot block the others
  // (or, more importantly, the UI thread on cold start).
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.yaqeen.audio',
      androidNotificationChannelName: 'يقين — القرآن والأذان',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  } catch (e) {
    debugPrint('JustAudioBackground.init failed: $e');
  }

  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  } catch (e) {
    debugPrint('AudioSession.configure failed: $e');
  }

  try {
    await PrayerNotificationService.initialize();
    await PrayerNotificationService.handleAppLaunchFromNotification();
  } catch (e) {
    debugPrint('PrayerNotificationService bootstrap failed: $e');
  }
}
