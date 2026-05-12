import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../models/quran_full_model.dart';

class QuranFullService {
  static const String _cdnBaseUrl = 'https://cdn.islamic.network/quran/images';

  /// Fetch full Quran in text format using the offline `quran_with_tafsir` data.
  /// 
  /// [edition] is kept for backward compatibility but has no effect on the
  /// underlying dataset (which is always Uthmani script from the package).
  static Future<QuranFullTextModel> getFullQuranText({
    String edition = 'quran-uthmani',
  }) async {
    try {
      final service = QuranService.instance;
      final List<SurahMetadata> surahsMeta = service.getAllSurahs();

      final surahsJson = surahsMeta.map((meta) {
        final surah = service.getSurah(meta.number);

        final ayahsJson = surah.verses
            .map((ayah) => {
                  'ayah_id': ayah.id,
                  'text': ayah.text,
                  'page': ayah.page,
                  'juz': ayah.juz,
                })
            .toList();

        return {
          'surah_id': meta.number,
          'name': meta.nameAr,
          'name_english': meta.nameEn,
          'revelation_type':
              meta.revelationType ?? (meta.isMeccan ? 'Meccan' : 'Medinan'),
          'number_of_ayahs': meta.ayahCount,
          'ayahs': ayahsJson,
        };
      }).toList();

      final transformedData = {
        'mushaf': edition,
        'total_surahs': surahsMeta.length,
        'surahs': surahsJson,
      };

      return QuranFullTextModel.fromJson(transformedData);
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('فشل تحميل القرآن الكريم: $e');
    }
  }

  /// Fetch full Quran in image format (pages 1-604).
  /// 
  /// This still uses static CDN image URLs but does not rely on any JSON APIs.
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

  /// Fetch a specific surah by ID using `quran_with_tafsir`.
  static Future<SurahTextModel> getSurahById(int surahId, {String edition = 'quran-uthmani'}) async {
    try {
      if (surahId < 1 || surahId > 114) {
        throw Exception('رقم السورة غير صحيح: $surahId');
      }

      final service = QuranService.instance;
      final meta = service.getSurahMetadata(surahId);
      final surah = service.getSurah(surahId);

      final ayahsJson = surah.verses
          .map((ayah) => {
                'ayah_id': ayah.id,
                'text': ayah.text,
                'page': ayah.page,
                'juz': ayah.juz,
              })
          .toList();

      final surahJson = {
        'surah_id': meta.number,
        'name': meta.nameAr,
        'name_english': meta.nameEn,
        'revelation_type':
            meta.revelationType ?? (meta.isMeccan ? 'Meccan' : 'Medinan'),
        'number_of_ayahs': meta.ayahCount,
        'ayahs': ayahsJson,
      };

      return SurahTextModel.fromJson(surahJson);
    } catch (e) {
      debugPrint('Error fetching surah: $e');
      rethrow;
    }
  }
  
  /// Get surah info (which pages it spans)
  static Future<Map<String, dynamic>> getSurahPageInfo(int surahId) async {
    try {
      final service = QuranService.instance;
      final surah = service.getSurah(surahId);
      
      // Get first and last page from ayahs
      int? firstPage;
      int? lastPage;
      
      for (final ayah in surah.verses) {
        firstPage ??= ayah.page;
        lastPage = ayah.page;
      }
      
      return {
        'surah_id': surahId,
        'name': service.getSurahNameArabic(surahId),
        'first_page': firstPage,
        'last_page': lastPage,
        'total_pages': (lastPage != null && firstPage != null) ? (lastPage - firstPage + 1) : 0,
      };
    } catch (e) {
      debugPrint('Error getting surah page info: $e');
      rethrow;
    }
  }
}

