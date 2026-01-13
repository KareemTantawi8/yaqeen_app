import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Service for Tafsir (Quran interpretation/commentary) APIs from gitea.com
/// 
/// Pattern: https://gitea.com/mostafamasri/tafsir-json/raw/branch/main/json/{tafsir_identifier}.json
/// 
/// All tafsirs are in Arabic language.
/// These JSON files contain verse-by-verse interpretations of the Quran.
class QuranTafsirService {
  static const String _baseUrl = 'https://gitea.com/mostafamasri/tafsir-json/raw/branch/main/json';
  
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

  /// Available tafsir identifiers
  static const Map<String, Map<String, String>> availableTafsirs = {
    'ar.muyassar': {
      'name': 'تفسير المیسر',
      'englishName': 'King Fahad Quran Complex',
      'language': 'ar',
    },
    'ar.jalalayn': {
      'name': 'تفسير الجلالين',
      'englishName': 'Jalal ad-Din al-Mahalli and Jalal ad-Din as-Suyuti',
      'language': 'ar',
    },
    'ar.waseet': {
      'name': 'الـتـفـسـيـر الـوسـيـط',
      'englishName': 'Tafsir Al Waseet',
      'language': 'ar',
    },
    'ar.baghawi': {
      'name': 'تفسير البغوي',
      'englishName': 'Tafsir Al Baghawi',
      'language': 'ar',
    },
    'ar.qurtubi': {
      'name': 'تفسير القرطبي',
      'englishName': 'Tafsir Al Qurtubi',
      'language': 'ar',
    },
    'ar.tanweer': {
      'name': 'تفسير التحرير والتنوير',
      'englishName': 'Tafsir Al Altahrir & Tanweer',
      'language': 'ar',
    },
    'ar.saddi': {
      'name': 'تفسير السعدي',
      'englishName': 'Tafsir Al Saddi',
      'language': 'ar',
    },
  };

  /// Fetch tafsir data for a specific tafsir
  /// 
  /// [tafsirIdentifier] - The tafsir identifier (e.g., 'ar.muyassar')
  /// Returns a Map containing tafsir data for all verses
  static Future<Map<String, dynamic>> getTafsirData(String tafsirIdentifier) async {
    try {
      if (!availableTafsirs.containsKey(tafsirIdentifier)) {
        throw Exception('Invalid tafsir identifier: $tafsirIdentifier');
      }

      final url = '$_baseUrl/$tafsirIdentifier.json';
      
      debugPrint('Fetching tafsir data from: $url');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch tafsir data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل التفسير: $e');
    }
  }

  /// Get tafsir for a specific verse
  /// 
  /// [tafsirIdentifier] - The tafsir identifier (e.g., 'ar.muyassar')
  /// [surahNumber] - Surah number (1-114)
  /// [ayahNumber] - Ayah number within the surah
  /// Returns the tafsir text for the specified verse, or null if not found
  static Future<String?> getVerseTafsir({
    required String tafsirIdentifier,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    try {
      final tafsirData = await getTafsirData(tafsirIdentifier);
      
      // The structure may vary, but typically it's organized by surah and ayah
      // Common structure: { "1": { "1": "tafsir text", ... }, ... }
      final surahKey = surahNumber.toString();
      final ayahKey = ayahNumber.toString();
      
      if (tafsirData.containsKey(surahKey)) {
        final surahData = tafsirData[surahKey] as Map<String, dynamic>?;
        if (surahData != null && surahData.containsKey(ayahKey)) {
          return surahData[ayahKey] as String?;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting verse tafsir: $e');
      return null;
    }
  }

  /// Get tafsir name in Arabic
  static String? getTafsirName(String tafsirIdentifier) {
    return availableTafsirs[tafsirIdentifier]?['name'];
  }

  /// Get tafsir name in English
  static String? getTafsirEnglishName(String tafsirIdentifier) {
    return availableTafsirs[tafsirIdentifier]?['englishName'];
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

