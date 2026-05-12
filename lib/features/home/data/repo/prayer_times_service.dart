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
        hijri: HijriDate(
          date: '01-01-1446',
          format: 'DD-MM-YYYY',
          day: '1',
          weekday: HijriWeekday(
            ar: 'الاثنين',
            en: 'Monday',
          ),
          month: HijriMonth(
            number: 1,
            en: 'Muharram',
            ar: 'محرم',
            days: 30,
          ),
          year: '1446',
        ),
      ),
      timings: Timings(
        fajr: timesMap['fajr'] ?? '00:00',
        sunrise: timesMap['sunrise'] ?? '00:00',
        dhuhr: timesMap['dhuhr'] ?? '00:00',
        asr: timesMap['asr'] ?? '00:00',
        sunset: timesMap['asr'] ?? '00:00',
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

  /// Get the next upcoming prayer
  static Map<String, dynamic> getNextPrayer(Timings timings) {
    // Re-calculate prayer times to get the PrayerTimes object
    try {
      final prayerTimes = PrayerCalculatorService.calculate();
      return PrayerCalculatorService.getNextPrayer(prayerTimes);
    } catch (e) {
      debugPrint('Error getting next prayer: $e');
      // Fallback
      return {
        'name': 'الفجر',
        'time': timings.fajr,
        'countdown': '00:00:00',
      };
    }
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
