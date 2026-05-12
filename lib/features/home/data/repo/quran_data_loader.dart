import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart' as qwt;
import '../models/surah_model.dart' as app_models;

class QuranDataLoader {
  /// Fetch all Surahs using the offline `quran_with_tafsir` metadata.
  static Future<List<app_models.Surah>> loadSurahs() async {
    try {
      final service = qwt.QuranService.instance;
      final List<qwt.SurahMetadata> metaList = service.getAllSurahs();

      return metaList
          .map(
            (meta) => app_models.Surah(
              number: meta.number,
              name: meta.nameAr,
              englishName: meta.nameEn,
              englishNameTranslation: '', // not provided by package
              numberOfAyahs: meta.ayahCount,
              revelationType:
                  meta.revelationType ?? (meta.isMeccan ? 'Meccan' : 'Medinan'),
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Error loading surahs: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Failed to load surahs: $e');
    }
  }
  
  /// Get a specific Surah with all Ayahs by number using `quran_with_tafsir`.
  static Future<Map<String, dynamic>> getSurahDetails(
    int surahNumber, {
    String edition = 'quran-simple',
  }) async {
    try {
      final service = qwt.QuranService.instance;

      final meta = service.getSurahMetadata(surahNumber);
      final surah = service.getSurah(surahNumber);

      final ayahsJson = surah.verses
          .map((ayah) => {
                'number': ayah.id,
                'text': ayah.text,
                'numberInSurah': ayah.id,
                'juz': ayah.juz,
                'manzil': 0,
                'page': ayah.page,
                'ruku': 0,
                'hizbQuarter': 0,
                'sajda': ayah.isSajda,
              })
          .toList();

      return {
        'number': meta.number,
        'name': meta.nameAr,
        'englishName': meta.nameEn,
        'englishNameTranslation': '',
        'revelationType':
            meta.revelationType ?? (meta.isMeccan ? 'Meccan' : 'Medinan'),
        'numberOfAyahs': meta.ayahCount,
        'ayahs': ayahsJson,
        'edition': null,
      };
    } catch (e) {
      debugPrint('Error loading surah details: $e');
      throw Exception('Failed to load surah details: $e');
    }
  }

  /// Get tafsir for a specific Surah using `quran_with_tafsir`.
  /// Returns Map<int, String> where key is ayah number and value is tafsir text.
  static Map<int, String> getTafsir(int surahNumber) {
    try {
      final service = qwt.QuranService.instance;
      return service.getTafsir(surahNumber);
    } catch (e) {
      debugPrint('Error loading tafsir: $e');
      return {};
    }
  }
}
