import 'package:flutter/foundation.dart';

/// Resolves bundled adhan audio assets for each voice.
class AdhanAudioCache {
  AdhanAudioCache._();

  static const bundledVoiceIds = {
    'makkah',
    'madinah',
    'mishary',
    'abdulbasit',
    'sudais',
  };

  static const Map<String, String> bundledAssets = {
    'makkah': 'assets/audio/adhan/makkah.mp3',
    'madinah': 'assets/audio/adhan/madinah.mp3',
    'mishary': 'assets/audio/adhan/mishary.mp3',
    'abdulbasit': 'assets/audio/adhan/abdulbasit.mp3',
    'sudais': 'assets/audio/adhan/sudais.mp3',
  };

  static Future<String> resolvePlayablePath(String voiceId) async {
    final path = bundledAssets[voiceId];
    if (path != null) return path;

    debugPrint('AdhanAudioCache: unknown voice $voiceId — using makkah');
    return bundledAssets['makkah']!;
  }
}
