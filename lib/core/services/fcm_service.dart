import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:yaqeen_app/core/services/prayer_notification_service.dart';
import 'package:yaqeen_app/core/utils/navigator_key.dart';
import 'package:yaqeen_app/firebase_options.dart';

/// Custom Yaqeen notification chime bundled as `yaqeen_notification.wav` (~1.25 s).
/// Android: `android/app/src/main/res/raw/yaqeen_notification.wav`
/// iOS: `ios/Runner/yaqeen_notification.caf` (Apple CAF format, in Copy Bundle Resources)
const _notificationSoundAndroid = 'yaqeen_notification';
const _notificationSoundIos = 'yaqeen_notification.caf';

// Must be top-level — executed in a background isolate when app is killed.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] Background message received: ${message.messageId}');

  // Notification-payload messages are already shown by Android / APNs.
  if (FCMService._isAutoDisplayedByPlatform(message)) return;
  if (!FCMService._consumeMessageOnce(message)) return;

  // Data-only push: show a local notification with the custom chime ourselves.
  final title = message.data['title'] as String?;
  final body = message.data['body'] as String?;
  if (title == null && body == null) return;

  await FCMService._ensureBackgroundPluginReady();
  await FCMService._showLocalNotification(
    id: FCMService._stableNotificationId(message),
    title: title ?? 'يقين',
    body: body ?? '',
    imageUrl: message.data['image'] as String?,
    plugin: FCMService._backgroundPlugin,
  );
}

class FCMService {
  FCMService._();

  static final _messaging = FirebaseMessaging.instance;

  // Background isolate only — foreground uses [PrayerNotificationService.notificationsPlugin].
  static final _backgroundPlugin = FlutterLocalNotificationsPlugin();

  // Bump the channel ID when the bundled sound file changes so Android
  // recreates the channel (channel sound is immutable once created).
  static const _channelId = 'fcm_notification_channel_v4';
  static const _channelName = 'إشعارات يقين';
  static const _legacyChannelIds = [
    'fcm_notification_channel',
    'fcm_default_channel',
    'fcm_notification_channel_v2',
    'fcm_notification_channel_v3',
  ];
  static const _pushChannel = MethodChannel('com.yaqeen.app/push');

  static const _androidSound = RawResourceAndroidNotificationSound(
    _notificationSoundAndroid,
  );

  static bool _backgroundPluginReady = false;

  // Prevents duplicate banners when FCM delivers the same message twice
  // (common on iOS 18 foreground) or when both the OS and our handler fire.
  static final Set<String> _recentMessageIds = {};

  /// True when the OS already displayed this push (Firebase Console sends a
  /// `notification` block). On Android the block may be stripped in the
  /// background isolate after auto-display, so we also check FCM data keys.
  static bool _isAutoDisplayedByPlatform(RemoteMessage message) {
    if (message.notification != null) return true;
    return message.data.containsKey('gcm.n.e') ||
        message.data['gcm.notification.e'] == '1';
  }

  static String? _messageKey(RemoteMessage message) {
    return message.messageId ??
        message.data['google.message_id'] as String? ??
        message.data['gcm.message_id'] as String?;
  }

  static bool _consumeMessageOnce(RemoteMessage message) {
    final key = _messageKey(message);
    if (key == null) return true;
    if (_recentMessageIds.contains(key)) return false;
    _recentMessageIds.add(key);
    Future<void>.delayed(const Duration(seconds: 30), () {
      _recentMessageIds.remove(key);
    });
    return true;
  }

  static int _stableNotificationId(RemoteMessage message) {
    final key = _messageKey(message);
    if (key != null) return key.hashCode;
    return message.hashCode;
  }

  static Future<void> _ensureBackgroundPluginReady() async {
    if (_backgroundPluginReady) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _backgroundPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    await _createAndroidChannel(_backgroundPlugin);
    if (Platform.isIOS) {
      final ios = _backgroundPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }
    _backgroundPluginReady = true;
  }

  static Future<void> initialize() async {
    // Register the background handler before any other FCM call.
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    await _requestPermissions();
    await _createAndroidChannel(PrayerNotificationService.notificationsPlugin);

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

    // On iOS suppress the system foreground banner — AppDelegate.willPresent
    // returns [] and we show a local notification with the custom chime instead.
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
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

  static Future<void> _createAndroidChannel(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    if (!Platform.isAndroid) return;
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    for (final legacyId in _legacyChannelIds) {
      await android?.deleteNotificationChannel(legacyId);
    }

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'إشعارات Firebase — نغمة يقين',
        sound: _androidSound,
        importance: Importance.high,
        showBadge: true,
        enableVibration: true,
        playSound: true,
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
  // Local notification helper (foreground + background data-only messages)
  // ---------------------------------------------------------------------------

  static Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
    FlutterLocalNotificationsPlugin? plugin,
  }) async {
    // Android details
    AndroidNotificationDetails androidDetails;
    if (imageUrl != null && Platform.isAndroid) {
      final bitmap = await _downloadBitmap(imageUrl);
      androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'إشعارات Firebase — نغمة يقين',
        importance: Importance.high,
        priority: Priority.high,
        sound: _androidSound,
        playSound: true,
        styleInformation: bitmap != null
            ? BigPictureStyleInformation(
                bitmap,
                contentTitle: title,
                summaryText: body,
                hideExpandedLargeIcon: true,
              )
            : const DefaultStyleInformation(true, true),
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'إشعارات Firebase — نغمة يقين',
        importance: Importance.high,
        priority: Priority.high,
        sound: _androidSound,
        playSound: true,
      );
    }

    // iOS details — download image to a temp file so it shows as an attachment
    DarwinNotificationDetails iosDetails;
    if (imageUrl != null && Platform.isIOS) {
      final imagePath = await _downloadImageToTemp(imageUrl);
      iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: _notificationSoundIos,
        attachments: imagePath != null
            ? [DarwinNotificationAttachment(imagePath)]
            : null,
        interruptionLevel: InterruptionLevel.active,
      );
    } else {
      iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: _notificationSoundIos,
        interruptionLevel: InterruptionLevel.active,
      );
    }

    final notificationsPlugin =
        plugin ?? PrayerNotificationService.notificationsPlugin;
    await notificationsPlugin.cancel(id);
    debugPrint('[FCM] Calling plugin.show id=$id title="$title"');
    await notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'fcm',
    );
    debugPrint('[FCM] plugin.show completed');
  }

  /// Downloads [url] to the system temp directory and returns the file path,
  /// or null on any error. Used for iOS notification image attachments.
  static Future<String?> _downloadImageToTemp(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final uri = Uri.parse(url);
      final rawExt = uri.pathSegments.last.split('.').lastOrNull ?? 'jpg';
      final ext = rawExt.split('?').first.toLowerCase();
      final safeExt =
          ['jpg', 'jpeg', 'png', 'gif'].contains(ext) ? ext : 'jpg';
      final file = File(
        '${Directory.systemTemp.path}/fcm_img_${DateTime.now().millisecondsSinceEpoch}.$safeExt',
      );
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) {
      debugPrint('[FCM] iOS image download failed: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Foreground message — show a local notification manually so the user sees
  // it immediately. Includes BigPicture style when notification carries an image.
  // ---------------------------------------------------------------------------

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM] Foreground message received: ${message.messageId}');
    debugPrint('[FCM] has notification: ${message.notification != null}');
    debugPrint('[FCM] data: ${message.data}');

    if (!_consumeMessageOnce(message)) {
      debugPrint('[FCM] Duplicate message — skipping');
      return;
    }

    final notification = message.notification;
    if (notification != null) {
      // iOS: AppDelegate suppresses the remote banner; show one local notification.
      // Android: FCM does not auto-display in foreground — show one local notification.
      final imageUrl =
          notification.apple?.imageUrl ?? notification.android?.imageUrl;
      debugPrint('[FCM] Showing local notification (imageUrl=$imageUrl)');
      await _showLocalNotification(
        id: _stableNotificationId(message),
        title: notification.title ?? 'يقين',
        body: notification.body ?? '',
        imageUrl: imageUrl,
      );
      return;
    }

    // Data-only foreground message.
    final title = message.data['title'] as String?;
    final body = message.data['body'] as String?;
    if (title == null && body == null) return;

    await _showLocalNotification(
      id: _stableNotificationId(message),
      title: title ?? 'يقين',
      body: body ?? '',
      imageUrl: message.data['image'] as String?,
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
    _openMainScreen();
  }

  /// Opens the main app shell. Deferred until [appNavigatorKey] is ready on cold start.
  static void _openMainScreen() {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      PrayerNotificationService.pendingOpenFromFcmNotification = true;
      return;
    }
    navigator.pushNamedAndRemoveUntil('/main', (route) => false);
  }
}
