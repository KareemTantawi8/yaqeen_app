import 'dart:math' show min, max;
import 'package:flutter/material.dart';
import '../../../../core/services/prayer_calculator_service.dart';
import '../models/prayer_timings_model.dart';

class PrayerTimesService {
  static const double defaultLatitude = 24.7406086;
  static const double defaultLongitude = 46.8060108;

  /// Fetch prayer times for a specific date using local calculation
  static Future<PrayerTimingsModel> getPrayerTimes({
    double? latitude,
    double? longitude,
    DateTime? date,
    int calculationMethodId = 4,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lon = longitude ?? defaultLongitude;
      final targetDate = date ?? DateTime.now();

      debugPrint('Calculating prayer times for: $lat, $lon on $targetDate');

      // Calculate using adhan_dart (local, offline)
      final prayerTimes = PrayerCalculatorService.calculate(
        latitude: lat,
        longitude: lon,
        date: targetDate,
        calculationMethodId: calculationMethodId,
      );

      // Get all times as formatted strings
      final timesMap = PrayerCalculatorService.getAllTimes(prayerTimes);

      // Build a PrayerTimingsModel
      return _buildPrayerTimingsModel(
        targetDate: targetDate,
        timesMap: timesMap,
        latitude: lat,
        longitude: lon,
      );
    } catch (e, stackTrace) {
      debugPrint('Error calculating prayer times: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Failed to calculate prayer times: $e');
    }
  }

  /// Build PrayerTimingsModel from calculated times
  static PrayerTimingsModel _buildPrayerTimingsModel({
    required DateTime targetDate,
    required Map<String, String> timesMap,
    required double latitude,
    required double longitude,
  }) {
    final dateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

    return PrayerTimingsModel(
      date: DateInfo(
        readable: _formatReadableDate(targetDate),
        timestamp: (targetDate.millisecondsSinceEpoch ~/ 1000).toString(),
        gregorian: GregorianDate(
          date: dateStr,
          format: 'YYYY-MM-DD',
          day: targetDate.day.toString(),
          weekday: GregorianWeekday(
            en: _getEnglishWeekday(targetDate.weekday),
          ),
          month: GregorianMonth(
            number: targetDate.month,
            en: _getEnglishMonth(targetDate.month),
          ),
          year: targetDate.year.toString(),
        ),
        hijri: _buildHijriDate(targetDate),
      ),
      timings: Timings(
        fajr: timesMap['fajr'] ?? '00:00',
        sunrise: timesMap['sunrise'] ?? '00:00',
        dhuhr: timesMap['dhuhr'] ?? '00:00',
        asr: timesMap['asr'] ?? '00:00',
        sunset: timesMap['sunset'] ?? '00:00',
        maghrib: timesMap['maghrib'] ?? '00:00',
        isha: timesMap['isha'] ?? '00:00',
        imsak: timesMap['fajr'] ?? '00:00',
        midnight: '00:00',
        firstthird: '00:00',
        lastthird: '00:00',
      ),
      meta: Meta(
        latitude: latitude,
        longitude: longitude,
        timezone: 'Asia/Riyadh',
      ),
    );
  }

  /// Next prayer for [latitude] / [longitude].
  /// Manually compares DateTime.now() against each prayer time in order
  /// so there is no dependency on adhan_dart's nextPrayer() enum, which
  /// returns Prayer.none after Isha and causes a crash → wrong Fajr fallback.
  static Map<String, dynamic> getNextPrayer(
    Timings timings, {
    required double latitude,
    required double longitude,
    int calculationMethodId = 4,
    DateTime? date,
  }) {
    try {
      final now = DateTime.now();

      final todayPT = PrayerCalculatorService.calculate(
        latitude: latitude,
        longitude: longitude,
        date: now,
        calculationMethodId: calculationMethodId,
      );

      // Walk today's prayers in order; return the first that is still future.
      // Sunrise is not a prayer obligation so it is excluded from this list.
      final candidates = <(String, DateTime)>[
        ('الفجر', todayPT.fajr),
        ('الظهر', todayPT.dhuhr),
        ('العصر', todayPT.asr),
        ('المغرب', todayPT.maghrib),
        ('العشاء', todayPT.isha),
      ];

      for (final (name, time) in candidates) {
        if (time.isAfter(now)) {
          return _result(name, time, now);
        }
      }

      // All of today's prayers have passed → show tomorrow's Fajr.
      final tomorrowPT = PrayerCalculatorService.calculate(
        latitude: latitude,
        longitude: longitude,
        date: now.add(const Duration(days: 1)),
        calculationMethodId: calculationMethodId,
      );
      return _result('الفجر', tomorrowPT.fajr, now);
    } catch (e) {
      debugPrint('Error getting next prayer: $e');
      return {'name': 'الفجر', 'time': timings.fajr, 'countdown': '00:00:00'};
    }
  }

  static Map<String, dynamic> _result(String name, DateTime time, DateTime now) {
    final diff = time.difference(now);
    return {
      'name': name,
      'time': PrayerCalculatorService.formatTime(time),
      'countdown': _fmt(diff),
      'duration': diff,
    };
  }

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Get prayer icon based on prayer name
  static String getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return 'assets/images/cloud-fog.png';
      case 'الظهر':
        return 'assets/images/sun2_icon.png';
      case 'العصر':
        return 'assets/images/sun_icon.png';
      case 'المغرب':
        return 'assets/images/cloud_sunny_widget.png';
      case 'العشاء':
        return 'assets/images/moon_icon.png';
      default:
        return 'assets/images/sun_icon.png';
    }
  }

  static HijriDate _buildHijriDate(DateTime date) {
    const List<String> monthNamesAr = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
    ];
    const List<String> monthNamesEn = [
      'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
      "Jumada al-Awwal", "Jumada al-Thani", 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", "Dhu al-Hijjah",
    ];

    final h = _gregorianToHijri(date.year, date.month, date.day);
    final int hYear  = h['year']!;
    final int hMonth = h['month']!;
    final int hDay   = h['day']!;

    return HijriDate(
      date: '$hDay-$hMonth-$hYear',
      format: 'DD-MM-YYYY',
      day: hDay.toString(),
      weekday: HijriWeekday(
        ar: _getArabicWeekday(date.weekday),
        en: _getEnglishWeekday(date.weekday),
      ),
      month: HijriMonth(
        number: hMonth,
        en: monthNamesEn[hMonth - 1],
        ar: monthNamesAr[hMonth - 1],
        days: 30,
      ),
      year: hYear.toString(),
    );
  }

  /// Gregorian → Julian Day Number (proleptic Gregorian calendar)
  static int _gregorianToJDN(int year, int month, int day) {
    final int a = (14 - month) ~/ 12;
    final int y = year + 4800 - a;
    final int m = month + 12 * a - 3;
    return day + (153 * m + 2) ~/ 5 + 365 * y +
        y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  }

  /// Julian Day Number → Hijri date (Tabular Islamic Calendar via fourmilab)
  static Map<String, int> _gregorianToHijri(int year, int month, int day) {
    const double epoch = 1948439.5;
    final double jd = _gregorianToJDN(year, month, day) + 0.5;

    final int hYear = ((30.0 * (jd - epoch) + 10646.0) / 10631.0).floor();
    final double jd1 = _islamicToJD(hYear, 1, 1);
    final int hMonth = max(1, min(12, ((jd - (29.0 + jd1)) / 29.5).ceil() + 1));
    final double jdm = _islamicToJD(hYear, hMonth, 1);
    final int hDay = ((jd - jdm).round() + 1).clamp(1, 30);

    return {'year': hYear, 'month': hMonth, 'day': hDay};
  }

  static double _islamicToJD(int year, int month, int day) {
    return day +
        (29.5 * (month - 1)).ceil().toDouble() +
        (year - 1) * 354.0 +
        ((3 + 11 * year) ~/ 30).toDouble() +
        1948439.5 - 1.0;
  }

  static String _getArabicWeekday(int weekday) {
    const weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return weekdays[weekday - 1];
  }

  static String _getEnglishWeekday(int weekday) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  static String _getEnglishMonth(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  static String _formatReadableDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
