import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/prayer_calculator_service.dart';
import '../models/adhan_model.dart';

class AdhanService {
  static const double defaultLatitude = 24.7406086;
  static const double defaultLongitude = 46.8060108;

  // Adhan audio files URLs
  static const Map<String, Map<String, String>> adhanSounds = {
    'makkah': {
      'name': 'أذان مكة المكرمة',
      'url': 'https://download.quranicaudio.com/quran/adhan/makkah.mp3',
    },
    'madina': {
      'name': 'أذان المدينة المنورة',
      'url': 'https://download.quranicaudio.com/quran/adhan/madina.mp3',
    },
    'abdulbasit': {
      'name': 'أذان عبد الباسط',
      'url': 'https://download.quranicaudio.com/quran/adhan/abdulbasit.mp3',
    },
  };

  static const String _selectedAdhanKey = 'selected_adhan_sound';

  /// Calculation methods for prayer times
  static const Map<int, String> calculationMethods = {
    1: 'جامعة العلوم الإسلامية، كراتشي',
    2: 'الرابطة الإسلامية لأمريكا الشمالية',
    3: 'رابطة العالم الإسلامي',
    4: 'أم القرى، مكة المكرمة',
    5: 'الهيئة المصرية العامة للمساحة',
    7: 'معهد الجيوفيزياء، جامعة طهران',
    8: 'الخليج',
    9: 'الكويت',
    10: 'قطر',
    11: 'مجلس الأوقاف، سنغافورة',
    12: 'فرنسا',
    13: 'تركيا',
    14: 'روسيا',
  };

  /// Fetch Adhan times by location using local calculation (adhan_dart)
  static Future<AdhanModel> getAdhanByLocation({
    required double latitude,
    required double longitude,
    int method = 4,
    bool useCache = true,
  }) async {
    try {
      final today = DateTime.now();

      debugPrint('Calculating Adhan times for: $latitude, $longitude');

      // Calculate using adhan_dart (local, offline)
      final prayerTimes = PrayerCalculatorService.calculate(
        latitude: latitude,
        longitude: longitude,
        date: today,
      );

      // Get all times as formatted strings
      final timesMap = PrayerCalculatorService.getAllTimes(prayerTimes);

      // Build AdhanModel from calculated PrayerTimes
      final adhanModel = AdhanModel(
        location: 'Calculated Location',
        date: DateFormat('dd MMM yyyy').format(today),
        timings: AdhanTimings(
          fajr: timesMap['fajr'] ?? '00:00',
          sunrise: timesMap['sunrise'] ?? '00:00',
          dhuhr: timesMap['dhuhr'] ?? '00:00',
          asr: timesMap['asr'] ?? '00:00',
          maghrib: timesMap['maghrib'] ?? '00:00',
          isha: timesMap['isha'] ?? '00:00',
        ),
        locationInfo: LocationInfo(
          latitude: latitude,
          longitude: longitude,
          timezone: 'Asia/Riyadh',
        ),
      );

      return adhanModel;
    } catch (e, stackTrace) {
      debugPrint('Error calculating adhan times: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل أوقات الأذان: $e');
    }
  }

  /// Get selected Adhan sound
  static Future<String> getSelectedAdhanSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedAdhanKey) ?? 'makkah'; // Default to Makkah
    } catch (e) {
      debugPrint('Error getting selected adhan sound: $e');
      return 'makkah';
    }
  }

  /// Save selected Adhan sound
  static Future<void> saveSelectedAdhanSound(String adhanId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedAdhanKey, adhanId);
      debugPrint('Saved selected adhan sound: $adhanId');
    } catch (e) {
      debugPrint('Error saving selected adhan sound: $e');
    }
  }

  /// Get selected Adhan sound URL
  static Future<String> getSelectedAdhanUrl() async {
    final selectedId = await getSelectedAdhanSound();
    return adhanSounds[selectedId]?['url'] ?? adhanSounds['makkah']!['url']!;
  }

  /// Get selected Adhan sound name
  static Future<String> getSelectedAdhanName() async {
    final selectedId = await getSelectedAdhanSound();
    return adhanSounds[selectedId]?['name'] ?? adhanSounds['makkah']!['name']!;
  }

  /// Get next prayer time and countdown
  static Map<String, dynamic> getNextPrayer(AdhanTimings timings) {
    // Re-calculate to get the PrayerTimes object
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

  /// Clear all cached Adhan data (kept for API compatibility, no-op for local calculation)
  static Future<void> clearAllCache() async {
    debugPrint('Local calculation mode - no cache to clear');
  }
}
