import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerCalculatorService {
  static const double defaultLatitude = 24.7406086;
  static const double defaultLongitude = 46.8060108;

  /// Calculate prayer times using adhan_dart (fully offline, locally)
  static PrayerTimes calculate({
    double? latitude,
    double? longitude,
    DateTime? date,
  }) {
    final lat = latitude ?? defaultLatitude;
    final lon = longitude ?? defaultLongitude;
    final d = date ?? DateTime.now();

    final coordinates = Coordinates(lat, lon);
    final params = CalculationMethodParameters.ummAlQura();

    return PrayerTimes(
      coordinates: coordinates,
      date: d,
      calculationParameters: params,
    );
  }

  /// Format DateTime to HH:mm string
  static String formatTime(DateTime? dt) {
    if (dt == null) return '00:00';
    try {
      return DateFormat('HH:mm').format(dt.toLocal());
    } catch (e) {
      return '00:00';
    }
  }

  /// Get all prayer times as formatted strings
  static Map<String, String> getAllTimes(PrayerTimes prayerTimes) {
    return {
      'fajr': formatTime(prayerTimes.fajr),
      'sunrise': formatTime(prayerTimes.sunrise),
      'dhuhr': formatTime(prayerTimes.dhuhr),
      'asr': formatTime(prayerTimes.asr),
      'maghrib': formatTime(prayerTimes.maghrib),
      'isha': formatTime(prayerTimes.isha),
    };
  }

  /// Get the current prayer name in Arabic
  static String getCurrentPrayerName(PrayerTimes prayerTimes) {
    try {
      final current = prayerTimes.currentPrayer();
      return _getPrayerNameArabic(current);
    } catch (e) {
      return 'الفجر';
    }
  }

  /// Get next prayer with countdown
  static Map<String, dynamic> getNextPrayer(PrayerTimes prayerTimes) {
    try {
      final now = DateTime.now();
      final nextPrayer = prayerTimes.nextPrayer();
      final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);

      final prayerName = _getPrayerNameArabic(nextPrayer);
      final countdown = nextPrayerTime.difference(now);

      return {
        'name': prayerName,
        'time': formatTime(nextPrayerTime),
        'countdown': _formatDuration(countdown),
        'duration': countdown,
      };
    } catch (e) {
      debugPrint('Error calculating next prayer: $e');
      return {
        'name': 'الفجر',
        'time': '00:00',
        'countdown': '00:00:00',
      };
    }
  }

  /// Get Sunnah times (night portions) from adhan_dart
  static SunnahTimes getSunnahTimes(PrayerTimes prayerTimes) {
    return SunnahTimes(prayerTimes);
  }

  /// Convert Prayer enum to Arabic name
  static String _getPrayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.ishaBefore:
        return 'العشاء';
      case Prayer.fajrAfter:
        return 'الفجر';
    }
  }

  /// Format duration to HH:mm:ss string
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
