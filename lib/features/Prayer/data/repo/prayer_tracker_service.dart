import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_completion_model.dart';
import '../models/prayer_stats_model.dart';

class PrayerTrackerService {
  static const String _completionPrefix = 'prayer_completion_';
  static const String _currentStreakKey = 'prayer_streak_current';
  static const String _longestStreakKey = 'prayer_streak_longest';
  static const String _lastCheckDateKey = 'prayer_last_check_date';

  // Prayer names in order
  static const List<String> prayerNames = [
    'الفجر',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء',
  ];

  /// Save prayer completion status
  static Future<bool> savePrayerCompletion(
      PrayerCompletionModel completion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCompletionKey(completion.date, completion.prayerName);
      final jsonString = jsonEncode(completion.toJson());
      await prefs.setString(key, jsonString);

      // Update streak if needed
      await _updateStreak();

      return true;
    } catch (e) {
      debugPrint('Error saving prayer completion: $e');
      return false;
    }
  }

  /// Get prayer completion for a specific date and prayer
  static Future<PrayerCompletionModel?> getPrayerCompletion(
      DateTime date, String prayerName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCompletionKey(date, prayerName);
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return PrayerCompletionModel.fromJson(json);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting prayer completion: $e');
      return null;
    }
  }

  /// Get all prayer completions for a specific date
  static Future<List<PrayerCompletionModel>> getPrayerCompletionsForDate(
      DateTime date) async {
    final completions = <PrayerCompletionModel>[];

    for (final prayerName in prayerNames) {
      final completion = await getPrayerCompletion(date, prayerName);
      if (completion != null) {
        completions.add(completion);
      } else {
        // Create default uncompleted prayer
        completions.add(
          PrayerCompletionModel(
            prayerId: '${_formatDate(date)}_$prayerName',
            prayerName: prayerName,
            date: date,
            isCompleted: false,
          ),
        );
      }
    }

    return completions;
  }

  /// Toggle prayer completion status
  static Future<bool> togglePrayerCompletion(
      DateTime date, String prayerName) async {
    final existing = await getPrayerCompletion(date, prayerName);

    if (existing != null) {
      // Toggle the completion status
      final updated = existing.copyWith(
        isCompleted: !existing.isCompleted,
        completionTime:
            !existing.isCompleted ? DateTime.now() : null,
      );
      return await savePrayerCompletion(updated);
    } else {
      // Create new completion
      final newCompletion = PrayerCompletionModel(
        prayerId: '${_formatDate(date)}_$prayerName',
        prayerName: prayerName,
        date: date,
        isCompleted: true,
        completionTime: DateTime.now(),
      );
      return await savePrayerCompletion(newCompletion);
    }
  }

  /// Get prayer statistics
  static Future<PrayerStatsModel> getPrayerStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Calculate stats for the last 30 days
      int totalPrayers = 0;
      int completedPrayers = 0;
      final prayerWiseStats = <String, int>{
        'الفجر': 0,
        'الظهر': 0,
        'العصر': 0,
        'المغرب': 0,
        'العشاء': 0,
      };

      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final completions = await getPrayerCompletionsForDate(date);

        for (final completion in completions) {
          totalPrayers++;
          if (completion.isCompleted) {
            completedPrayers++;
            prayerWiseStats[completion.prayerName] =
                (prayerWiseStats[completion.prayerName] ?? 0) + 1;
          }
        }
      }

      final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
      final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
      final missedPrayers = totalPrayers - completedPrayers;
      final completionPercentage =
          totalPrayers > 0 ? (completedPrayers / totalPrayers) * 100 : 0.0;

      return PrayerStatsModel(
        totalPrayers: totalPrayers,
        completedPrayers: completedPrayers,
        missedPrayers: missedPrayers,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        completionPercentage: completionPercentage,
        prayerWiseStats: prayerWiseStats,
      );
    } catch (e) {
      debugPrint('Error getting prayer stats: $e');
      return PrayerStatsModel.empty();
    }
  }

  /// Update prayer streak
  static Future<void> _updateStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Check if all prayers for today are completed
      final todayCompletions = await getPrayerCompletionsForDate(today);
      final allTodayCompleted =
          todayCompletions.every((c) => c.isCompleted);

      if (allTodayCompleted) {
        // Check yesterday's completions
        final yesterdayCompletions =
            await getPrayerCompletionsForDate(yesterday);
        final allYesterdayCompleted =
            yesterdayCompletions.every((c) => c.isCompleted);

        int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;

        if (allYesterdayCompleted) {
          // Continue streak
          currentStreak++;
        } else {
          // Start new streak
          currentStreak = 1;
        }

        await prefs.setInt(_currentStreakKey, currentStreak);

        // Update longest streak if needed
        final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
        if (currentStreak > longestStreak) {
          await prefs.setInt(_longestStreakKey, currentStreak);
        }

        // Update last check date
        await prefs.setString(_lastCheckDateKey, _formatDate(today));
      }
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  /// Get completion percentage for today
  static Future<double> getTodayCompletionPercentage() async {
    final today = DateTime.now();
    final completions = await getPrayerCompletionsForDate(today);
    final completed = completions.where((c) => c.isCompleted).length;
    return (completed / prayerNames.length) * 100;
  }

  /// Get number of completed prayers for today
  static Future<int> getTodayCompletedCount() async {
    final today = DateTime.now();
    final completions = await getPrayerCompletionsForDate(today);
    return completions.where((c) => c.isCompleted).length;
  }

  /// Helper to generate storage key
  static String _getCompletionKey(DateTime date, String prayerName) {
    return '$_completionPrefix${_formatDate(date)}_$prayerName';
  }

  /// Helper to format date as string
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Clear all prayer data (for testing or reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(_completionPrefix) ||
          key == _currentStreakKey ||
          key == _longestStreakKey ||
          key == _lastCheckDateKey) {
        await prefs.remove(key);
      }
    }
  }
}

