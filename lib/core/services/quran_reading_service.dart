import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgress {
  final int surahNumber;
  final String surahName;
  final String surahEnglishName;
  final int ayahNumber;
  final String ayahText;
  final int totalAyahs;
  final DateTime lastRead;

  ReadingProgress({
    required this.surahNumber,
    required this.surahName,
    required this.surahEnglishName,
    required this.ayahNumber,
    required this.ayahText,
    required this.totalAyahs,
    required this.lastRead,
  });

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'surahEnglishName': surahEnglishName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'totalAyahs': totalAyahs,
      'lastRead': lastRead.toIso8601String(),
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
      surahEnglishName: json['surahEnglishName'] as String,
      ayahNumber: json['ayahNumber'] as int,
      ayahText: json['ayahText'] as String,
      totalAyahs: json['totalAyahs'] as int,
      lastRead: DateTime.parse(json['lastRead'] as String),
    );
  }

  double get progressPercentage => (ayahNumber / totalAyahs * 100).clamp(0.0, 100.0);
}

class BookmarkedAyah {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final DateTime bookmarkedAt;

  BookmarkedAyah({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.bookmarkedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
    };
  }

  factory BookmarkedAyah.fromJson(Map<String, dynamic> json) {
    return BookmarkedAyah(
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
      ayahNumber: json['ayahNumber'] as int,
      ayahText: json['ayahText'] as String,
      bookmarkedAt: DateTime.parse(json['bookmarkedAt'] as String),
    );
  }
}

class QuranReadingService {
  static const String _keyReadingProgress = 'reading_progress';
  static const String _keyBookmarks = 'quran_bookmarks';

  // Save reading progress
  static Future<void> saveReadingProgress(ReadingProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(progress.toJson());
      await prefs.setString(_keyReadingProgress, jsonString);
      debugPrint('Reading progress saved: Surah ${progress.surahNumber}, Ayah ${progress.ayahNumber}');
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
    }
  }

  // Get reading progress
  static Future<ReadingProgress?> getReadingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyReadingProgress);
      
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return ReadingProgress.fromJson(json);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting reading progress: $e');
      return null;
    }
  }

  // Add bookmark
  static Future<void> addBookmark(BookmarkedAyah bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks();
      
      // Check if already bookmarked
      final exists = bookmarks.any(
        (b) => b.surahNumber == bookmark.surahNumber && 
               b.ayahNumber == bookmark.ayahNumber,
      );
      
      if (!exists) {
        bookmarks.add(bookmark);
        final jsonList = bookmarks.map((b) => b.toJson()).toList();
        await prefs.setString(_keyBookmarks, jsonEncode(jsonList));
        debugPrint('Bookmark added: Surah ${bookmark.surahNumber}, Ayah ${bookmark.ayahNumber}');
      }
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
    }
  }

  // Remove bookmark
  static Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks();
      
      bookmarks.removeWhere(
        (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
      );
      
      final jsonList = bookmarks.map((b) => b.toJson()).toList();
      await prefs.setString(_keyBookmarks, jsonEncode(jsonList));
      debugPrint('Bookmark removed: Surah $surahNumber, Ayah $ayahNumber');
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }

  // Get all bookmarks
  static Future<List<BookmarkedAyah>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyBookmarks);
      
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList
            .map((json) => BookmarkedAyah.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error getting bookmarks: $e');
      return [];
    }
  }

  // Check if ayah is bookmarked
  static Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.any(
        (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
      );
    } catch (e) {
      debugPrint('Error checking bookmark: $e');
      return false;
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyReadingProgress);
      await prefs.remove(_keyBookmarks);
      debugPrint('All Quran reading data cleared');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}

