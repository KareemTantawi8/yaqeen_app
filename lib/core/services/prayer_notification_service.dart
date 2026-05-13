import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yaqeen_app/core/utils/navigator_key.dart';
import 'prayer_calculator_service.dart';

// Must be top-level — runs in a background isolate when app is killed
@pragma('vm:entry-point')
void _backgroundNotificationHandler(NotificationResponse response) {
  debugPrint('[BG] Prayer notification received: ${response.payload}');
}

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'adhan_prayer_channel';
  static const _channelName = 'أوقات الصلاة';
  static const _channelDesc = 'إشعارات أوقات الصلاة والأذان';

  static const _keyEnabled = 'adhan_notifications_enabled';
  static const _keyPrayerPrefix = 'prayer_notif_enabled_';

  static const _prayerIds = <String, int>{
    'الفجر': 100,
    'الظهر': 101,
    'العصر': 102,
    'المغرب': 103,
    'العشاء': 104,
  };

  static const List<String> prayerNames = [
    'الفجر',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء',
  ];

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  static Future<void> initialize() async {
    // Timezone database + detect device timezone
    tz.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      debugPrint('Timezone detection failed, falling back to UTC: $e');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onForegroundTap,
      onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
    );

    // Create dedicated high-importance channel on Android
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
    }

    debugPrint('PrayerNotificationService: initialized');
  }

  // Called when user taps a notification while app is in foreground / background
  static void _onForegroundTap(NotificationResponse response) {
    final prayerName = response.payload ?? '';
    debugPrint('Prayer notification tapped: $prayerName');
    _navigateToAdhan(prayerName);
  }

  static void _navigateToAdhan(String prayerName) {
    appNavigatorKey.currentState?.pushNamed(
      '/adhan-full',
      arguments: {'prayerName': prayerName, 'autoPlay': true},
    );
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  static Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final notif = await Permission.notification.request();
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      debugPrint('Notification permission: $notif');
      return notif.isGranted;
    }

    return true;
  }

  // Check whether the app was launched by tapping a notification
  static Future<void> handleAppLaunchFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      final payload = details?.notificationResponse?.payload ?? '';
      if (payload.isNotEmpty) {
        // Defer until the navigator is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToAdhan(payload);
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------------

  static Future<void> schedulePrayerNotifications({
    required double latitude,
    required double longitude,
  }) async {
    if (!await areNotificationsEnabled()) return;

    final prayerTimes = PrayerCalculatorService.calculate(
      latitude: latitude,
      longitude: longitude,
    );
    final now = DateTime.now();

    final schedule = <String, DateTime?>{
      'الفجر': prayerTimes.fajr,
      'الظهر': prayerTimes.dhuhr,
      'العصر': prayerTimes.asr,
      'المغرب': prayerTimes.maghrib,
      'العشاء': prayerTimes.isha,
    };

    for (final entry in schedule.entries) {
      final name = entry.key;
      final time = entry.value;
      if (time == null) continue;

      final enabled = await getPrayerNotificationEnabled(name);
      if (!enabled) {
        await _cancelById(_prayerIds[name]!);
        continue;
      }

      if (time.isAfter(now)) {
        await _scheduleOne(name, time);
      }
    }

    debugPrint('PrayerNotificationService: scheduled today\'s prayers');
  }

  static Future<void> _scheduleOne(
    String prayerName,
    DateTime prayerTime,
  ) async {
    try {
      final id = _prayerIds[prayerName]!;
      final tzTime = tz.TZDateTime.from(prayerTime, tz.local);

      await _plugin.zonedSchedule(
        id,
        'حان وقت صلاة $prayerName',
        'اضغط لسماع الأذان',
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prayerName,
      );

      debugPrint('Scheduled: $prayerName at $prayerTime');
    } catch (e) {
      debugPrint('Failed to schedule $prayerName: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Cancellation
  // ---------------------------------------------------------------------------

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('PrayerNotificationService: all notifications cancelled');
  }

  static Future<void> _cancelById(int id) async {
    await _plugin.cancel(id);
  }

  // ---------------------------------------------------------------------------
  // Preferences
  // ---------------------------------------------------------------------------

  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
    if (!enabled) await cancelAll();
  }

  static Future<bool> getPrayerNotificationEnabled(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrayerPrefix$prayerName') ?? true;
  }

  static Future<void> setPrayerNotificationEnabled(
    String prayerName,
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrayerPrefix$prayerName', enabled);
    if (!enabled) await _cancelById(_prayerIds[prayerName]!);
  }
}
