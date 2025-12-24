import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_timings_model.dart';

class PrayerTimesService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  
  // Default coordinates (Riyadh, Saudi Arabia)
  static const double defaultLatitude = 24.7406086;
  static const double defaultLongitude = 46.8060108;
  static const int method = 1; // University of Islamic Sciences, Karachi

  /// Fetch prayer times for a specific date
  static Future<PrayerTimingsModel> getPrayerTimes({
    double? latitude,
    double? longitude,
    DateTime? date,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lon = longitude ?? defaultLongitude;
      final targetDate = date ?? DateTime.now();
      
      // Format date as DD-MM-YYYY
      final formattedDate = DateFormat('dd-MM-yyyy').format(targetDate);
      
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final url = '/timings/$formattedDate';
      final queryParams = {
        'latitude': lat,
        'longitude': lon,
        'method': method,
      };

      debugPrint('Fetching prayer times from: $baseUrl$url');
      debugPrint('Query params: $queryParams');

      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        dynamic data = response.data;

        // Manually parse if the response is a String
        if (data is String) {
          data = jsonDecode(data);
        }

        if (data is Map && data['code'] == 200 && data['data'] != null) {
          return PrayerTimingsModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load prayer times: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to load prayer times';
      if (e.response != null) {
        errorMessage += ': ${e.response?.statusCode} - ${e.response?.statusMessage}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage += ': Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage += ': Receive timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage += ': Connection error - ${e.message}';
      } else {
        errorMessage += ': ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Failed to load prayer times: $e');
    }
  }

  /// Get the next upcoming prayer
  static Map<String, dynamic> getNextPrayer(Timings timings) {
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
}

