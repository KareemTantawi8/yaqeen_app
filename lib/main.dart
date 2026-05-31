import 'package:audio_session/audio_session.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaqeen_app/core/services/fcm_service.dart';
import 'package:yaqeen_app/core/services/prayer_notification_service.dart';
import 'package:yaqeen_app/core/services/service_locator.dart';
import 'package:yaqeen_app/firebase_options.dart';
import 'package:yaqeen_app/yaqeen_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _ignoreSimulatorMetaKeyAssertionInDebug();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupServiceLocator();

  // Configure the audio session for music so all just_audio players get
  // correct audio focus on both iOS and Android.
  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  } catch (e) {
    debugPrint('AudioSession.configure failed: $e');
  }

  // Initialize and request notification permissions BEFORE runApp so that
  // HomeScreen.initState → schedulePrayerNotifications never races with
  // plugin initialization (addPostFrameCallback fires after the first frame,
  // by which time HomeScreen has already tried to schedule notifications).
  try {
    await PrayerNotificationService.initialize();
    await PrayerNotificationService.requestPermissions();
    await PrayerNotificationService.handleAppLaunchFromNotification();
  } catch (e) {
    debugPrint('PrayerNotificationService bootstrap failed: $e');
  }

  try {
    await FCMService.initialize();
  } catch (e) {
    debugPrint('FCMService bootstrap failed: $e');
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
}

void _ignoreSimulatorMetaKeyAssertionInDebug() {
  final previousOnError = FlutterError.onError;

  FlutterError.onError = (details) {
    if (kDebugMode && _isSimulatorMetaKeyAssertion(details)) {
      return;
    }

    previousOnError?.call(details);
  };
}

bool _isSimulatorMetaKeyAssertion(FlutterErrorDetails details) {
  final exception = details.exceptionAsString();
  final stack = details.stack?.toString() ?? '';

  return exception.contains('A KeyUpEvent is dispatched') &&
      exception.contains('Meta Left') &&
      stack.contains('hardware_keyboard.dart');
}
