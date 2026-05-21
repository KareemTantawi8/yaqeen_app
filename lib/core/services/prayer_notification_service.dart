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

  static const _channelDesc = 'إشعارات أوقات الصلاة والأذان';

  static const _keyEnabled = 'adhan_notifications_enabled';
  static const _keyPrayerPrefix = 'prayer_notif_enabled_';

  // Per-voice channel IDs and names
  static const Map<String, String> _voiceChannels = {
    'makkah': 'أذان مكة المكرمة',
    'madinah': 'أذان المدينة المنورة',
    'mishary': 'مشاري راشد العفاسي',
    'abdulbasit': 'عبد الباسط عبد الصمد',
    'sudais': 'عبد الرحمن السديس',
  };

  static String _channelId(String voiceId) => 'adhan_voice_$voiceId';

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

    // Create one high-importance channel per voice with its custom Adhan sound
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      for (final entry in _voiceChannels.entries) {
        final voiceId = entry.key;
        final voiceName = entry.value;
        await android?.createNotificationChannel(
          AndroidNotificationChannel(
            _channelId(voiceId),
            voiceName,
            description: _channelDesc,
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound(voiceId),
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
      }
    }

    debugPrint('PrayerNotificationService: initialized');
  }

  /// Set by [handleAppLaunchFromNotification] when the app is cold-launched from
  /// a notification tap. HomeScreen reads and clears this after the splash screen
  /// finishes, then opens the adhan popup.
  static String? pendingAdhanPrayerName;

  // Called when user taps a notification while app is in foreground / background
  static void _onForegroundTap(NotificationResponse response) {
    final prayerName = response.payload ?? '';
    debugPrint('Prayer notification tapped: $prayerName');
    // App is already running — navigator is ready, push the alert screen directly.
    appNavigatorKey.currentState?.pushNamed(
      '/adhan-alert',
      arguments: {'prayerName': prayerName},
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

  // Check whether the app was cold-launched by tapping a notification.
  // Rather than navigating immediately (the splash screen isn't done yet),
  // we store the prayer name. HomeScreen picks it up after the splash.
  static Future<void> handleAppLaunchFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      final payload = details?.notificationResponse?.payload ?? '';
      if (payload.isNotEmpty) {
        pendingAdhanPrayerName = payload;
        debugPrint('App launched from adhan notification: $payload');
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

    // Determine which Adhan voice the user has selected
    final prefs = await SharedPreferences.getInstance();
    String voiceId = prefs.getString('selected_adhan_voice_id') ??
        prefs.getString('selected_adhan_sound') ??
        'makkah';
    if (!_voiceChannels.containsKey(voiceId)) voiceId = 'makkah';

    final channelId = _channelId(voiceId);
    final channelName = _voiceChannels[voiceId]!;

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
        await _scheduleOne(name, time, channelId, channelName, voiceId);
      }
    }

    debugPrint(
        'PrayerNotificationService: scheduled today\'s prayers (voice=$voiceId)');
  }

  /// Cancel pending notification for a specific prayer (used when in-app popup handles it).
  static Future<void> cancelPrayerNotification(String prayerName) async {
    final id = _prayerIds[prayerName];
    if (id != null) await _plugin.cancel(id);
  }

  static Future<void> _scheduleOne(
    String prayerName,
    DateTime prayerTime,
    String channelId,
    String channelName,
    String voiceId,
  ) async {
    try {
      final id = _prayerIds[prayerName]!;
      // Explicitly cancel any previous notification with this ID before rescheduling
      // to prevent duplicate plays on devices where zonedSchedule doesn't overwrite.
      await _plugin.cancel(id);
      final tzTime = tz.TZDateTime.from(prayerTime, tz.local);

      await _plugin.zonedSchedule(
        id,
        'حان وقت صلاة $prayerName',
        'اضغط لسماع الأذان',
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: _channelDesc,
            // Sound is set on the channel; reference it here too so the OS
            // uses the correct one when the channel already exists.
            sound: RawResourceAndroidNotificationSound(voiceId),
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
            sound: '$voiceId.mp3',
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prayerName,
      );

      debugPrint('Scheduled: $prayerName at $prayerTime (voice=$voiceId)');
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
