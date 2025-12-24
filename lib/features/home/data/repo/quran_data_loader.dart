import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/surah_model.dart';

class QuranDataLoader {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  
  /// Fetch all Surahs from AlQuran API
  static Future<List<Surah>> loadSurahs() async {
    try {
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

      debugPrint('Fetching surahs from: $baseUrl/surah');

      final response = await dio.get(
        '/surah',
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

        // Check if response has the expected structure
        if (data is Map && data['code'] == 200 && data['data'] != null) {
          final jsonList = data['data'] as List<dynamic>;
          return jsonList
              .map((json) => Surah.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load surahs: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to load surahs';
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
      debugPrint(errorMessage);
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      debugPrint('Error loading surahs: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Failed to load surahs: $e');
    }
  }
  
  /// Get a specific Surah with all Ayahs by number
  static Future<Map<String, dynamic>> getSurahDetails(
    int surahNumber, {
    String edition = 'quran-simple',
  }) async {
    try {
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

      debugPrint('Fetching surah $surahNumber details with edition: $edition');

      final response = await dio.get(
        '/surah/$surahNumber/$edition',
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
        if (data is String) {
          data = jsonDecode(data);
        }
        
        if (data is Map && data['code'] == 200 && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load surah details: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to load surah details';
      if (e.response != null) {
        errorMessage += ': ${e.response?.statusCode} - ${e.response?.statusMessage}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage += ': Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage += ': Receive timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage += ': Connection error';
      } else {
        errorMessage += ': ${e.message}';
      }
      debugPrint(errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error loading surah details: $e');
      throw Exception('Failed to load surah details: $e');
    }
  }
}
