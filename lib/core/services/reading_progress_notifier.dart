import 'package:flutter/foundation.dart';
import 'quran_reading_service.dart';

/// Notifier for reading progress changes
/// This allows widgets to listen to updates without hot reload
class ReadingProgressNotifier extends ChangeNotifier {
  static final ReadingProgressNotifier _instance = ReadingProgressNotifier._internal();
  
  factory ReadingProgressNotifier() {
    return _instance;
  }
  
  ReadingProgressNotifier._internal();

  ReadingProgress? _progress;
  ReadingProgress? get progress => _progress;

  /// Load the current reading progress
  Future<void> loadProgress() async {
    _progress = await QuranReadingService.getReadingProgress();
    notifyListeners();
  }

  /// Update and notify about progress change
  Future<void> updateProgress(ReadingProgress progress) async {
    await QuranReadingService.saveReadingProgress(progress);
    _progress = progress;
    notifyListeners();
  }

  /// Clear progress
  Future<void> clearProgress() async {
    _progress = null;
    notifyListeners();
  }
}

