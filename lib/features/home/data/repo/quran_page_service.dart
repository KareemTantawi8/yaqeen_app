import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

/// Service for loading Quran pages using the offline `quran_with_tafsir` data.
class QuranPageService {
  /// Get verses for a specific page (1-604)
  static Future<Map<String, dynamic>> getPageVerses(int pageNumber) async {
    try {
      if (pageNumber < 1 || pageNumber > 604) {
        throw Exception('Page number must be between 1 and 604');
      }

      final service = QuranService.instance;
      final List<Ayah> ayahs = service.getPage(pageNumber);

      final verses = ayahs
          .map((ayah) => {
                'verse_key': '${ayah.surahNumber}:${ayah.id}',
                'text_uthmani_simple': ayah.text,
                'page': ayah.page,
                'juz': ayah.juz,
                'words': <Map<String, dynamic>>[],
              })
          .toList();

      final data = {
        'page': pageNumber,
        'verses': verses,
      };

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

