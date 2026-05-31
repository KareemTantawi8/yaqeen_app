import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:yaqeen_app/firebase_options.dart';

// Must be top-level — executed in a background isolate when app is killed.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] Background message received: ${message.messageId}');
}

class FCMService {
  FCMService._();

  static final _messaging = FirebaseMessaging.instance;

  // A dedicated plugin instance for FCM foreground notifications.
  // We intentionally do NOT call initialize() on it so we don't override
  // the onDidReceiveNotificationResponse callback set by PrayerNotificationService.
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'fcm_default_channel';
  static const _channelName = 'إشعارات يقين';
  static const _pushChannel = MethodChannel('com.yaqeen.app/push');

  static Future<void> initialize() async {
    // Register the background handler before any other FCM call.
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    await _requestPermissions();
    await _createAndroidChannel();

    // iOS: FCM needs an APNS token before getToken/subscribeToTopic.
    await _registerForRemoteNotificationsIfNeeded();
    await _waitForApnsTokenIfNeeded();
    await _subscribeToAllTopic();
    await _printToken();
    _scheduleTokenRetries();

    // Foreground: Firebase doesn't show a heads-up by default — we do it manually.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Tapped while app was in background (but not killed).
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    // Tapped when app was fully terminated.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationTap(initial);
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] permission status: ${settings.authorizationStatus}');

    // On iOS show heads-up banner even when app is in foreground.
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> _registerForRemoteNotificationsIfNeeded() async {
    if (!Platform.isIOS) return;
    try {
      await _pushChannel.invokeMethod<void>('registerForRemoteNotifications');
      debugPrint('[FCM] requested APNS registration');
    } catch (e) {
      debugPrint('[FCM] APNS registration request failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Android notification channel
  // ---------------------------------------------------------------------------

  static Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
            showBadge: true,
            enableVibration: true,
          ),
        );
  }

  // ---------------------------------------------------------------------------
  // iOS APNS — required before any FCM token or topic call
  // ---------------------------------------------------------------------------

  static Future<void> _waitForApnsTokenIfNeeded() async {
    if (!Platform.isIOS) return;

    for (var attempt = 0; attempt < 20; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        debugPrint('[FCM] APNS token received');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    debugPrint(
      '[FCM] APNS token not ready yet — will keep retrying in background',
    );
  }

  static void _scheduleTokenRetries() {
    if (!Platform.isIOS) return;

    for (final delay in [3, 10, 30]) {
      Future<void>.delayed(Duration(seconds: delay), () async {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('[FCM] retry $delay s: APNS still not ready');
          await _registerForRemoteNotificationsIfNeeded();
          return;
        }
        debugPrint('[FCM] retry $delay s: APNS ready, fetching FCM token');
        await _subscribeToAllTopic();
        await _fetchAndPrintToken();
      });
    }
  }

  static Future<void> _fetchAndPrintToken() async {
    if (!await _ensureFcmReady()) return;

    try {
      final token = await _messaging.getToken();
      debugPrint('========== FCM TOKEN ==========');
      debugPrint(token ?? 'null');
      debugPrint('================================');
    } catch (e) {
      debugPrint('[FCM] getToken failed: $e');
    }
  }

  static Future<bool> _ensureFcmReady() async {
    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Topic subscription — send from Firebase console to topic "all" to reach
  // every device that has installed the app.
  // ---------------------------------------------------------------------------

  static Future<void> _subscribeToAllTopic() async {
    if (!await _ensureFcmReady()) return;

    try {
      await _messaging.subscribeToTopic('all');
      debugPrint('[FCM] Subscribed to topic: all');
    } catch (e) {
      debugPrint('[FCM] Topic subscription deferred: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  static Future<void> _printToken() async {
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('========== FCM TOKEN REFRESHED ==========');
      debugPrint(newToken);
      debugPrint('=========================================');
      await _subscribeToAllTopic();
    });

    await _fetchAndPrintToken();
  }

  // ---------------------------------------------------------------------------
  // Foreground message — show a local notification manually so the user sees
  // it immediately. Includes BigPicture style when notification carries an image.
  // ---------------------------------------------------------------------------

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final imageUrl =
        notification.android?.imageUrl ?? notification.apple?.imageUrl;

    AndroidNotificationDetails androidDetails;

    if (imageUrl != null && Platform.isAndroid) {
      final bitmap = await _downloadBitmap(imageUrl);
      androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: bitmap != null
            ? BigPictureStyleInformation(
                bitmap,
                contentTitle: notification.title,
                summaryText: notification.body,
                hideExpandedLargeIcon: true,
              )
            : const DefaultStyleInformation(true, true),
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      );
    }

    await _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Image download helper
  // ---------------------------------------------------------------------------

  static Future<ByteArrayAndroidBitmap?> _downloadBitmap(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return ByteArrayAndroidBitmap(response.bodyBytes);
      }
    } catch (e) {
      debugPrint('[FCM] Failed to download notification image: $e');
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Notification tap handler
  // ---------------------------------------------------------------------------

  static void _onNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped — data: ${message.data}');
    // TODO: Navigate based on message.data fields when needed.
  }
}
