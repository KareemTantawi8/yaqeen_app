import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

/// Service for accessing Tafsir data using the offline `quran_with_tafsir` package.
/// 
/// The underlying package provides Tafsir Al-Muyassar for all 114 surahs.
class QuranTafsirService {
  /// Available tafsir identifiers
  static const Map<String, Map<String, String>> availableTafsirs = {
    'ar.muyassar': {
      'name': 'تفسير المیسر',
      'englishName': 'King Fahad Quran Complex',
      'language': 'ar',
    },
  };

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
      if (!availableTafsirs.containsKey(tafsirIdentifier)) {
        throw Exception('Invalid tafsir identifier: $tafsirIdentifier');
      }

      final service = QuranService.instance;
      final Map<int, String> tafsirMap = service.getTafsir(surahNumber);
      return tafsirMap[ayahNumber];
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
}

