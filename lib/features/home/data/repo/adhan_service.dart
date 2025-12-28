import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/adhan_model.dart';
import 'package:intl/intl.dart';

class AdhanService {
  // Use Aladhan API - External Public API
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static const String _cacheKey = 'adhan_cache';
  static const String _cacheTimeKey = 'adhan_cache_time';
  static const Duration _cacheDuration = Duration(hours: 24);
  
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

  /// Fetch Adhan times by location from Aladhan API
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  /// [method] - Calculation method (default: 4 - Umm al-Qura)
  /// [useCache] - Use cached data if available (default: true)
  static Future<AdhanModel> getAdhanByLocation({
    required double latitude,
    required double longitude,
    int method = 4,
    bool useCache = true,
  }) async {
    try {
      // Check cache first
      if (useCache) {
        final cachedData = await _getCachedAdhan(latitude, longitude);
        if (cachedData != null) {
          debugPrint('Using cached Adhan data');
          return cachedData;
        }
      }

      // Aladhan API endpoint: https://api.aladhan.com/v1/timings
      final url = '$_baseUrl/timings';
      final today = DateTime.now();
      final timestamp = today.millisecondsSinceEpoch ~/ 1000;
      
      final queryParams = {
        'latitude': latitude,
        'longitude': longitude,
        'method': method,
        'timestamp': timestamp,
      };

      debugPrint('Fetching Adhan times from: $url');
      debugPrint('Query params: $queryParams');

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['code'] == 200) {
          final responseData = data['data'];
          
          // Transform Aladhan API format to our model format
          final transformedData = {
            'location': responseData['meta']?['timezone'] ?? 'Unknown',
            'date': responseData['date']?['readable'] ?? DateFormat('dd MMM yyyy').format(today),
            'timings': responseData['timings'],
            'location_info': {
              'latitude': latitude,
              'longitude': longitude,
              'timezone': responseData['meta']?['timezone'],
            },
          };
          
          final adhanModel = AdhanModel.fromJson(transformedData);
          
          // Cache the result
          await _cacheAdhan(latitude, longitude, adhanModel);
          
          return adhanModel;
        } else {
          throw Exception('صيغة استجابة غير متوقعة');
        }
      } else {
        throw Exception('فشل تحميل أوقات الأذان: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل أوقات الأذان: $e');
    }
  }

  /// Get cached Adhan data
  static Future<AdhanModel?> _getCachedAdhan(
    double latitude,
    double longitude,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimeStr = prefs.getString('${_cacheTimeKey}_${latitude}_$longitude');
      final cacheData = prefs.getString('${_cacheKey}_${latitude}_$longitude');

      if (cacheTimeStr == null || cacheData == null) {
        return null;
      }

      final cacheTime = DateTime.parse(cacheTimeStr);
      final now = DateTime.now();

      // Check if cache is still valid
      if (now.difference(cacheTime) < _cacheDuration) {
        final data = jsonDecode(cacheData);
        return AdhanModel.fromJson(data);
      } else {
        // Cache expired, remove it
        await _clearCache(latitude, longitude);
        return null;
      }
    } catch (e) {
      debugPrint('Error reading cache: $e');
      return null;
    }
  }

  /// Cache Adhan data
  static Future<void> _cacheAdhan(
    double latitude,
    double longitude,
    AdhanModel adhanModel,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = jsonEncode(adhanModel.toJson());
      final cacheTime = DateTime.now().toIso8601String();

      await prefs.setString('${_cacheKey}_${latitude}_$longitude', cacheData);
      await prefs.setString('${_cacheTimeKey}_${latitude}_$longitude', cacheTime);
      
      debugPrint('Adhan data cached successfully');
    } catch (e) {
      debugPrint('Error caching Adhan data: $e');
    }
  }

  /// Clear cached Adhan data
  static Future<void> _clearCache(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_cacheKey}_${latitude}_$longitude');
      await prefs.remove('${_cacheTimeKey}_${latitude}_$longitude');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Clear all cached Adhan data
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cacheKey) || key.startsWith(_cacheTimeKey)) {
          await prefs.remove(key);
        }
      }
      
      debugPrint('All Adhan cache cleared');
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  /// Get next prayer time and countdown
  static Map<String, dynamic> getNextPrayer(AdhanTimings timings) {
    final now = DateTime.now();
    final prayers = {
      'الفجر': _parseTime(timings.fajr),
      'الظهر': _parseTime(timings.dhuhr),
      'العصر': _parseTime(timings.asr),
      'المغرب': _parseTime(timings.maghrib),
      'العشاء': _parseTime(timings.isha),
    };

    DateTime? nextPrayerTime;
    String? nextPrayerName;

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        nextPrayerTime = entry.value;
        nextPrayerName = entry.key;
        break;
      }
    }

    // If no prayer found today, next prayer is Fajr tomorrow
    if (nextPrayerTime == null || nextPrayerName == null) {
      nextPrayerTime = _parseTime(timings.fajr).add(const Duration(days: 1));
      nextPrayerName = 'الفجر';
    }

    final duration = nextPrayerTime.difference(now);
    
    return {
      'name': nextPrayerName,
      'time': _formatTime(nextPrayerTime),
      'duration': duration,
      'countdown': _formatDuration(duration),
    };
  }

  /// Parse time string (HH:mm) to DateTime
  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Format DateTime to time string (HH:mm)
  static String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Format duration to countdown string
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Helper method to handle Dio errors
  static String _handleDioError(DioException e) {
    if (e.response != null) {
      return 'خطأ في الاتصال: ${e.response?.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة استقبال البيانات';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'خطأ في الاتصال بالإنترنت';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }
}

