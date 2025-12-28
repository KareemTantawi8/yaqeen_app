import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/surah_full_model.dart';

class SurahFullService {
  // Use AlQuran Cloud API - External Public API
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  
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

  /// Available reciters list with their AlQuran Cloud API identifiers
  static final List<ReciterModel> availableReciters = [
    ReciterModel(
      id: 'ar.alafasy',
      name: 'Mishary Alafasy',
      nameArabic: 'مشاري العفاسي',
    ),
    ReciterModel(
      id: 'ar.abdulbasitmurattal',
      name: 'Abdul Basit (Murattal)',
      nameArabic: 'عبد الباسط عبد الصمد',
    ),
    ReciterModel(
      id: 'ar.husary',
      name: 'Mahmoud Khalil Al-Husary',
      nameArabic: 'محمود خليل الحصري',
    ),
    ReciterModel(
      id: 'ar.abdurrahmanalsudais',
      name: 'Abdurrahman As-Sudais',
      nameArabic: 'عبد الرحمن السديس',
    ),
    ReciterModel(
      id: 'ar.shaatree',
      name: 'Abu Bakr Ash-Shaatree',
      nameArabic: 'أبو بكر الشاطري',
    ),
    ReciterModel(
      id: 'ar.minshawi',
      name: 'Mohamed Siddiq Al-Minshawi',
      nameArabic: 'محمد صديق المنشاوي',
    ),
    ReciterModel(
      id: 'ar.hanirifai',
      name: 'Hani Ar-Rifai',
      nameArabic: 'هاني الرفاعي',
    ),
  ];

  /// Fetch full surah with audio from AlQuran Cloud API
  /// [surahId] - Surah number (1-114)
  /// [reciter] - Reciter ID (default: ar.alafasy)
  static Future<SurahFullModel> getFullSurah({
    required int surahId,
    String reciter = 'ar.alafasy',
    bool audio = true,
  }) async {
    try {
      if (surahId < 1 || surahId > 114) {
        throw Exception('رقم السورة غير صحيح: $surahId');
      }

      // AlQuran Cloud API format: /surah/{number}/{edition}
      // Example: https://api.alquran.cloud/v1/surah/1/ar.alafasy
      final edition = audio ? reciter : 'quran-uthmani';
      final url = '$_baseUrl/surah/$surahId/$edition';
      
      debugPrint('Fetching full surah from: $url');

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
          final surahData = data['data'];
          
          // Transform AlQuran Cloud format to our model format
          final transformedData = {
            'surah_id': surahData['number'],
            'name': surahData['name'],
            'name_english': surahData['englishName'],
            'reciter': reciter,
            'audio_url': null, // AlQuran Cloud doesn't provide full surah audio URL
            'ayahs': (surahData['ayahs'] as List).map((ayah) {
              return {
                'ayah_id': ayah['numberInSurah'],
                'text': ayah['text'],
                'audio': audio && ayah['audio'] != null ? ayah['audio'] : null,
                'page': ayah['page'],
              };
            }).toList(),
          };
          
          return SurahFullModel.fromJson(transformedData);
        } else {
          throw Exception('صيغة استجابة غير متوقعة');
        }
      } else {
        throw Exception('فشل تحميل السورة: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل السورة: $e');
    }
  }

  /// Get reciter by ID
  static ReciterModel? getReciterById(String reciterId) {
    try {
      return availableReciters.firstWhere((r) => r.id == reciterId);
    } catch (e) {
      return null;
    }
  }

  /// Get reciter name in Arabic
  static String getReciterNameArabic(String reciterId) {
    final reciter = getReciterById(reciterId);
    return reciter?.nameArabic ?? reciterId;
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

