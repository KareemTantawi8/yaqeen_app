/// Helpers for Quran Arabic text from the `quran_with_tafsir` package.
class QuranTextUtils {
  /// KFG Hafs Uthmanic Script encodes end-of-ayah markers in U+FC00–U+FDFF.
  /// With fonts like Amiri Quran they render as stray characters (e.g. ئج).
  static final RegExp _ayahMarkerPattern = RegExp(r'[\uFC00-\uFDFF]');

  static String withoutAyahMarkers(String text) {
    return text.replaceAll(_ayahMarkerPattern, '').trimRight();
  }
}
