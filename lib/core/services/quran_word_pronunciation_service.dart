import 'package:flutter/material.dart';

/// Service for word-by-word pronunciation audio from quranwbw.com
/// 
/// Format: https://words.audios.quranwbw.com/{surah_number}/{surah_id}_{verse_id}_{word_position}.mp3
/// 
/// - Surah number: 1-114 (no padding)
/// - Surah ID, Verse ID, and Word Position are zero-padded to 3 digits
/// - Example: Surah 1, Verse 1, Word 1 = 1/001_001_001.mp3
class QuranWordPronunciationService {
  static const String _baseUrl = 'https://words.audios.quranwbw.com';

  /// Get word pronunciation audio URL
  /// 
  /// [surahNumber] - Surah number (1-114, no padding)
  /// [surahId] - Surah ID (zero-padded to 3 digits, e.g., 001, 002, ..., 114)
  /// [verseId] - Verse ID (zero-padded to 3 digits, e.g., 001, 002, ...)
  /// [wordPosition] - Word position in verse (zero-padded to 3 digits, e.g., 001, 002, ...)
  static String getWordPronunciationUrl({
    required int surahNumber,
    required int surahId,
    required int verseId,
    required int wordPosition,
  }) {
    final surahIdPadded = surahId.toString().padLeft(3, '0');
    final verseIdPadded = verseId.toString().padLeft(3, '0');
    final wordPositionPadded = wordPosition.toString().padLeft(3, '0');
    
    return '$_baseUrl/$surahNumber/${surahIdPadded}_${verseIdPadded}_$wordPositionPadded.mp3';
  }

  /// Get word pronunciation audio URL (convenience method with auto-padding)
  static String getWordPronunciationUrlSimple({
    required int surahNumber,
    required int verseNumber,
    required int wordPosition,
  }) {
    return getWordPronunciationUrl(
      surahNumber: surahNumber,
      surahId: surahNumber,
      verseId: verseNumber,
      wordPosition: wordPosition,
    );
  }
}

