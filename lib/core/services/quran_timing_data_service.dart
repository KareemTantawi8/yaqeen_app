import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../features/home/data/models/reciter_model.dart';

/// Service for Quran timing data from gitea.com
/// 
/// These JSON files contain timing data for word-by-word audio synchronization.
/// 
/// Pattern: https://gitea.com/mostafamasri/quran_timing_data/raw/branch/main/{reader_identifier}.json
/// 
/// Used for synchronizing word highlighting with audio playback.
class QuranTimingDataService {
  static const String _baseUrl = 'https://gitea.com/mostafamasri/quran_timing_data/raw/branch/main';
  
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Fetch timing data for a specific reciter
  /// 
  /// [reciter] - The reciter to get timing data for
  /// Returns a Map containing timing data for all verses
  static Future<Map<String, dynamic>> getTimingData(Reciter reciter) async {
    try {
      final url = '$_baseUrl/${reciter.identifier}.json';
      
      debugPrint('Fetching timing data from: $url');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch timing data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل بيانات التوقيت: $e');
    }
  }

  /// Fetch timing data for a specific reciter by identifier
  /// 
  /// [reciterIdentifier] - The reciter identifier (e.g., 'Abdul_Basit_Mujawwad_128kbps')
  static Future<Map<String, dynamic>> getTimingDataByIdentifier(String reciterIdentifier) async {
    try {
      final url = '$_baseUrl/$reciterIdentifier.json';
      
      debugPrint('Fetching timing data from: $url');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch timing data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل بيانات التوقيت: $e');
    }
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

