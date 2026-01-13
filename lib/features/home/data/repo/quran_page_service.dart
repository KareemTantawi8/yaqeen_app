import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/services/quran_com_api_service.dart';

/// Service for loading Quran pages using Quran.com API
/// Replaces the old alquran.cloud API with the new Quran.com API
class QuranPageService {
  /// Get verses for a specific page (1-604)
  static Future<Map<String, dynamic>> getPageVerses(int pageNumber) async {
    try {
      if (pageNumber < 1 || pageNumber > 604) {
        throw Exception('Page number must be between 1 and 604');
      }

      final data = await QuranComApiService.getVersesByPage(
        pageNumber: pageNumber,
        includeWords: true,
        wordFields: 'v2_page,location,text_uthmani,codeV2',
        verseFields: 'text_uthmani_simple',
      );

      return data;
    } catch (e) {
      debugPrint('Error loading page $pageNumber: $e');
      rethrow;
    }
  }

  /// Get multiple pages at once
  static Future<List<Map<String, dynamic>>> getPagesVerses(List<int> pageNumbers) async {
    try {
      final futures = pageNumbers.map((page) => getPageVerses(page));
      return await Future.wait(futures);
    } catch (e) {
      debugPrint('Error loading pages: $e');
      rethrow;
    }
  }

  /// Extract surah information from page data
  static Map<String, dynamic>? extractSurahInfo(Map<String, dynamic> pageData) {
    try {
      final verses = pageData['verses'] as List<dynamic>?;
      if (verses == null || verses.isEmpty) return null;

      final firstVerse = verses.first as Map<String, dynamic>;
      final verseKey = firstVerse['verse_key'] as String?;
      
      if (verseKey != null) {
        final parts = verseKey.split(':');
        if (parts.length >= 1) {
          return {
            'surah_number': int.tryParse(parts[0]) ?? 0,
            'first_ayah': parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0,
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error extracting surah info: $e');
      return null;
    }
  }
}

