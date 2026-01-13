import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Service for Quran.com API v4 - Get verses by page number
/// 
/// Endpoint: https://api.quran.com/api/v4/verses/by_page/{page_number}
/// 
/// Total Pages: 604
/// 
/// Query Parameters:
/// - words: true (to include word-level data)
/// - word_fields: v2_page,location,text_uthmani,codeV2
/// - fields: text_uthmani_simple
class QuranComApiService {
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  
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

  /// Fetch verses by page number with word-level data
  /// 
  /// [pageNumber] - Page number (1-604)
  /// [includeWords] - Whether to include word-level data (default: true)
  /// [wordFields] - Fields to include for words (default: v2_page,location,text_uthmani,codeV2)
  /// [verseFields] - Fields to include for verses (default: text_uthmani_simple)
  static Future<Map<String, dynamic>> getVersesByPage({
    required int pageNumber,
    bool includeWords = true,
    String wordFields = 'v2_page,location,text_uthmani,codeV2',
    String verseFields = 'text_uthmani_simple',
  }) async {
    try {
      if (pageNumber < 1 || pageNumber > 604) {
        throw Exception('Page number must be between 1 and 604');
      }

      final url = '$_baseUrl/verses/by_page/$pageNumber';
      
      final queryParams = <String, dynamic>{
        'words': includeWords.toString(),
        'word_fields': wordFields,
        'fields': verseFields,
      };

      debugPrint('Fetching verses by page from: $url');
      debugPrint('Query params: $queryParams');

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch verses: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل الآيات: $e');
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

