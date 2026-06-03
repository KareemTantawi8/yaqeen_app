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
  static const _iosAdhanSound = 'yaqeen_notification.caf';

  /// Shared plugin instance — FCM foreground notifications must use this so
  /// taps are handled by [_onForegroundTap] (only one plugin per app).
  static FlutterLocalNotificationsPlugin get notificationsPlugin => _plugin;

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

  // Notification IDs: prayerIndex * 10 + dayOffset (0–6).
  // فجر=0..6, ظهر=10..16, عصر=20..26, مغرب=30..36, عشاء=40..46.
  // Legacy single-day IDs (100–104) are cancelled on first reschedule.
  static const _prayerIndices = <String, int>{
    'الفجر': 0,
    'الظهر': 1,
    'العصر': 2,
    'المغرب': 3,
    'العشاء': 4,
  };
  static const _daysAhead = 7;

  static int _notifId(String prayerName, int dayOffset) =>
      (_prayerIndices[prayerName] ?? 0) * 10 + dayOffset;

  static Future<void> _cancelPrayerAllDays(String prayerName) async {
    final base = _prayerIndices[prayerName] ?? 0;
    for (var d = 0; d < _daysAhead; d++) {
      await _plugin.cancel(base * 10 + d);
    }
    // Cancel legacy single-day ID from older builds
    await _plugin.cancel(base + 100);
  }

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
    await _initLocalTimezone();

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
  /// a prayer notification tap. HomeScreen reads and clears this after the splash
  /// screen finishes, then opens the adhan popup.
  static String? pendingAdhanPrayerName;

  /// True when the app was cold-launched from an FCM local notification tap.
  /// HomeScreen clears this without opening the adhan popup.
  static bool pendingOpenFromFcmNotification = false;

  // Called when user taps any local notification (prayer or FCM foreground).
  static void _onForegroundTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    debugPrint('Notification tapped: $payload');

    if (prayerNames.contains(payload)) {
      // Prayer notification → open adhan alert popup.
      appNavigatorKey.currentState?.pushNamed(
        '/adhan-alert',
        arguments: {'prayerName': payload},
      );
    } else if (payload == 'fcm') {
      // FCM foreground notification → open main screen.
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
    }
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
      final ok = granted ?? false;
      debugPrint('PrayerNotificationService: iOS permission=$ok');
      return ok;
    }

    if (Platform.isAndroid) {
      final notif = await Permission.notification.request();
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      debugPrint('PrayerNotificationService: Android notification=$notif');
      return notif.isGranted;
    }

    return true;
  }

  /// Whether the OS allows showing/scheduling notifications (separate from app toggle).
  static Future<bool> hasSystemNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.status;
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  /// Schedules a one-shot test notification (default 15s) to verify alarms work.
  static Future<bool> scheduleTestNotification({
    Duration delay = const Duration(seconds: 15),
  }) async {
    if (!await hasSystemNotificationPermission()) {
      debugPrint('PrayerNotificationService: test skipped — no OS permission');
      return false;
    }

    const testId = 9999;
    await _plugin.cancel(testId);

    final prefs = await SharedPreferences.getInstance();
    String voiceId = prefs.getString('selected_adhan_voice_id') ??
        prefs.getString('selected_adhan_sound') ??
        'makkah';
    if (!_voiceChannels.containsKey(voiceId)) voiceId = 'makkah';

    final fireAt = tz.TZDateTime.now(tz.local).add(delay);
    try {
      await _plugin.zonedSchedule(
        testId,
        'تجربة إشعار يقين',
        'إذا ظهر هذا الإشعار، أوقات الصلاة تعمل بشكل صحيح',
        fireAt,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId(voiceId),
            _voiceChannels[voiceId]!,
            channelDescription: _channelDesc,
            sound: RawResourceAndroidNotificationSound(voiceId),
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: _iosAdhanSound,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'test',
      );
      debugPrint(
        'PrayerNotificationService: test notification at $fireAt (in ${delay.inSeconds}s)',
      );
      return true;
    } catch (e) {
      debugPrint('PrayerNotificationService: test schedule failed: $e');
      return false;
    }
  }

  static Future<void> _initLocalTimezone() async {
    tz.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
      debugPrint('PrayerNotificationService: timezone=$localTz');
      return;
    } catch (e) {
      debugPrint('FlutterTimezone failed: $e');
    }

    // Fallback: build a fixed-offset location from the device clock.
    final offset = DateTime.now().timeZoneOffset;
    final location = tz.Location(
      'DeviceLocal',
      const <int>[],
      const <int>[],
      [
        tz.TimeZone(
          offset.inMilliseconds,
          isDst: false,
          abbreviation: 'LOCAL',
        ),
      ],
    );
    tz.setLocalLocation(location);
    debugPrint(
      'PrayerNotificationService: using device offset ${offset.inHours}h',
    );
  }

  /// adhan_dart returns UTC [DateTime]s; convert to a [tz.TZDateTime] in [tz.local].
  static tz.TZDateTime _prayerUtcToTz(DateTime prayerTime) {
    final local = prayerTime.toLocal();
    return tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
    );
  }

  static bool _isPrayerInFuture(DateTime prayerTime) {
    return prayerTime.toLocal().isAfter(DateTime.now());
  }

  // Check whether the app was cold-launched by tapping a notification.
  // Rather than navigating immediately (the splash screen isn't done yet),
  // we store the prayer name. HomeScreen picks it up after the splash.
  static Future<void> handleAppLaunchFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return;

    final payload = details?.notificationResponse?.payload ?? '';
    if (prayerNames.contains(payload)) {
      pendingAdhanPrayerName = payload;
      debugPrint('App launched from adhan notification: $payload');
    } else if (payload == 'fcm') {
      pendingOpenFromFcmNotification = true;
      debugPrint('App launched from FCM notification');
    }
  }

  // ---------------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------------

  static Future<void> schedulePrayerNotifications({
    required double latitude,
    required double longitude,
  }) async {
    if (!await areNotificationsEnabled()) {
      debugPrint('PrayerNotificationService: app notifications disabled');
      return;
    }

    if (!await hasSystemNotificationPermission()) {
      debugPrint(
        'PrayerNotificationService: OS notification permission denied — skipping schedule',
      );
      return;
    }

    // Replace any stale alarms (legacy IDs, old location/method) before scheduling.
    await cancelAll();

    final prefs = await SharedPreferences.getInstance();
    String voiceId = prefs.getString('selected_adhan_voice_id') ??
        prefs.getString('selected_adhan_sound') ??
        'makkah';
    if (!_voiceChannels.containsKey(voiceId)) voiceId = 'makkah';

    final channelId = _channelId(voiceId);
    final channelName = _voiceChannels[voiceId]!;
    final calculationMethodId = prefs.getInt('prayer_calculation_method') ?? 4;
    final now = DateTime.now();

    for (var dayOffset = 0; dayOffset < _daysAhead; dayOffset++) {
      final dayDate = DateTime(now.year, now.month, now.day + dayOffset);
      final prayerTimes = PrayerCalculatorService.calculate(
        latitude: latitude,
        longitude: longitude,
        calculationMethodId: calculationMethodId,
        date: dayDate,
      );

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
          // Cancel all days for this prayer when first encountered as disabled
          if (dayOffset == 0) await _cancelPrayerAllDays(name);
          continue;
        }

        if (_isPrayerInFuture(time)) {
          await _scheduleOne(
            _notifId(name, dayOffset),
            name,
            time,
            channelId,
            channelName,
            voiceId,
          );
        }
      }
    }

    final pending = await _plugin.pendingNotificationRequests();
    debugPrint(
      'PrayerNotificationService: scheduled $_daysAhead-day prayers '
      '(voice=$voiceId, pending=${pending.length})',
    );
  }

  /// Cancel all scheduled notifications for a prayer across all days.
  /// Called when the in-app adhan popup is about to play so the OS doesn't
  /// also fire the banner while the user is already listening.
  static Future<void> cancelPrayerNotification(String prayerName) async {
    await _cancelPrayerAllDays(prayerName);
  }

  static Future<void> _scheduleOne(
    int id,
    String prayerName,
    DateTime prayerTime,
    String channelId,
    String channelName,
    String voiceId,
  ) async {
    try {
      await _plugin.cancel(id);
      final tzTime = _prayerUtcToTz(prayerTime);

      AndroidScheduleMode androidScheduleMode =
          AndroidScheduleMode.exactAllowWhileIdle;
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final canScheduleExact =
            await android?.canScheduleExactNotifications() ?? true;
        if (!canScheduleExact) {
          // Keep prayer reminders working even when "Alarms & reminders"
          // permission is denied by the user/device policy.
          androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
          debugPrint(
            'Exact alarms not allowed; falling back to inexact schedule for $prayerName',
          );
        }
      }

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
            // iOS local-notification sounds must be in an Apple-supported
            // format (CAF/WAV/AIFF). MP3-based per-voice names are ignored on
            // many release devices, resulting in silent notifications.
            sound: _iosAdhanSound,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prayerName,
      );

      debugPrint(
        'Scheduled: $prayerName at ${prayerTime.toLocal()} → $tzTime (voice=$voiceId)',
      );
    } catch (e, st) {
      debugPrint('Failed to schedule $prayerName: $e\n$st');
    }
  }

  // ---------------------------------------------------------------------------
  // Cancellation
  // ---------------------------------------------------------------------------

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('PrayerNotificationService: all notifications cancelled');
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
    if (!enabled) await _cancelPrayerAllDays(prayerName);
  }
}
