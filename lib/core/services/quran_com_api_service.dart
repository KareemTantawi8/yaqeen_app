import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

/// Offline Quran "API" adapter backed by `quran_with_tafsir`.
/// 
/// This keeps the old method signature but no longer performs any
/// HTTP requests. All data is loaded from the embedded Quran dataset.
class QuranComApiService {
  /// Fetch verses by page number with word-level data
  /// 
  /// [pageNumber] - Page number (1-604)
  /// 
  /// The returned map mimics the old Quran.com v4 response shape
  /// for the fields actually used in the app:
  /// 
  /// {
  ///   "verses": [
  ///     {
  ///       "verse_key": "1:1",
  ///       "text_uthmani_simple": "...",
  ///       "page": 1,
  ///       "juz": 1,
  ///       // "words": [] // left empty, since we do not have word data
  ///     },
  ///     ...
  ///   ]
  /// }
  static Future<Map<String, dynamic>> getVersesByPage({
    required int pageNumber,
  }) async {
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
                // Word-level data is not available from quran_with_tafsir.
                'words': <Map<String, dynamic>>[],
              })
          .toList();

      return {
        'verses': verses,
      };
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل الآيات: $e');
    }
  }
}

