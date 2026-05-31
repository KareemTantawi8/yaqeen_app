import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../utils/quran_text_utils.dart';
import 'quran_reading_service.dart';
import 'reading_progress_notifier.dart';

/// Saves reading marker / resume position from mushaf [Ayah] data.
class QuranMushafProgress {
  static Future<void> saveFromAyah(Ayah ayah) async {
    final meta = QuranService.instance.getSurahMetadata(ayah.surahNumber);
    final text = QuranTextUtils.withoutAyahMarkers(ayah.text);
    final progress = ReadingProgress(
      surahNumber: ayah.surahNumber,
      surahName: meta.nameAr,
      surahEnglishName: meta.nameEn,
      ayahNumber: ayah.id,
      ayahText: text.length > 100 ? text.substring(0, 100) : text,
      totalAyahs: meta.ayahCount,
      lastRead: DateTime.now(),
      pageNumber: ayah.page,
    );

    await ReadingProgressNotifier().updateProgress(progress);
  }

  static Future<void> clear() async {
    await ReadingProgressNotifier().clearProgress();
  }

  static int resolveMushafPage(ReadingProgress progress) {
    if (progress.pageNumber != null) {
      return progress.pageNumber!.clamp(1, 604);
    }
    final page = QuranService.instance.getPageNumber(
      progress.surahNumber,
      progress.ayahNumber,
    );
    return (page ?? 1).clamp(1, 604);
  }
}
