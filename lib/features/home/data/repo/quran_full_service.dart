import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/quran_full_model.dart';

class QuranFullService {
  // Use AlQuran Cloud API - External Public API
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _cdnBaseUrl = 'https://cdn.islamic.network/quran/images';
  
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

  /// Fetch full Quran in text format from AlQuran Cloud API
  /// [edition] - Type of Quran edition (quran-uthmani, quran-simple, etc.)
  static Future<QuranFullTextModel> getFullQuranText({
    String edition = 'quran-uthmani',
  }) async {
    try {
      // AlQuran Cloud API endpoint for full Quran
      final url = '$_baseUrl/quran/$edition';
      
      debugPrint('Fetching full Quran text from: $url');

      final response = await _dio.get(
        url,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['code'] == 200) {
          // Extract the 'data' object which contains surahs
          final quranData = data['data'];
          
          // Transform AlQuran Cloud format to our model format
          final transformedData = {
            'mushaf': edition,
            'total_surahs': quranData['surahs']?.length ?? 114,
            'surahs': quranData['surahs'],
          };
          
          return QuranFullTextModel.fromJson(transformedData);
        } else {
          throw Exception('Unexpected response format: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load full Quran: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل القرآن الكريم: $e');
    }
  }

  /// Fetch full Quran in image format (pages 1-604)
  /// Uses CDN images from Islamic Network
  static Future<QuranFullImageModel> getFullQuranImages() async {
    try {
      debugPrint('Generating Quran page URLs from CDN');

      // Generate all 604 pages
      final pages = <QuranPageModel>[];
      for (int i = 1; i <= 604; i++) {
        pages.add(QuranPageModel(
          page: i,
          imageUrl: '$_cdnBaseUrl/$i.png',
        ));
      }

      return QuranFullImageModel(
        type: 'image',
        pages: pages,
      );
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل صفحات المصحف: $e');
    }
  }

  /// Fetch a specific surah by ID from AlQuran Cloud API
  static Future<SurahTextModel> getSurahById(int surahId, {String edition = 'quran-uthmani'}) async {
    try {
      if (surahId < 1 || surahId > 114) {
        throw Exception('رقم السورة غير صحيح: $surahId');
      }

      final url = '$_baseUrl/surah/$surahId/$edition';
      debugPrint('Fetching surah from: $url');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['code'] == 200) {
          return SurahTextModel.fromJson(data['data']);
        }
      }
      
      throw Exception('فشل تحميل السورة');
    } catch (e) {
      debugPrint('Error fetching surah: $e');
      rethrow;
    }
  }
  
  /// Get surah info (which pages it spans)
  static Future<Map<String, dynamic>> getSurahPageInfo(int surahId) async {
    try {
      final surah = await getSurahById(surahId);
      
      // Get first and last page from ayahs
      int? firstPage;
      int? lastPage;
      
      for (final ayah in surah.ayahs) {
        if (ayah.page != null) {
          firstPage ??= ayah.page;
          lastPage = ayah.page;
        }
      }
      
      return {
        'surah_id': surahId,
        'name': surah.name,
        'first_page': firstPage,
        'last_page': lastPage,
        'total_pages': (lastPage != null && firstPage != null) ? (lastPage - firstPage + 1) : 0,
      };
    } catch (e) {
      debugPrint('Error getting surah page info: $e');
      rethrow;
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

