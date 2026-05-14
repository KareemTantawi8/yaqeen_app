import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhanAudioPlayerService {
  AdhanAudioPlayerService._internal() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
      } else {
        _isPlaying = state.playing;
      }
    });
  }

  static final AdhanAudioPlayerService instance =
      AdhanAudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = false;

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  static const _keySelectedVoice = 'selected_adhan_voice_id';
  static const _legacyKeySelectedSound = 'selected_adhan_sound';

  // Bundled adhan (remote quranicaudio URLs 404; cleartext HTTP mirrors are blocked on Android).
  static const List<Map<String, String>> voices = [
    {
      'id': 'makkah',
      'name': 'أذان مكة المكرمة',
      'asset': 'assets/audio/adhan/makkah.mp3',
    },
    {
      'id': 'madinah',
      'name': 'أذان المدينة المنورة',
      'asset': 'assets/audio/adhan/madinah.mp3',
    },
    {
      'id': 'mishary',
      'name': 'مشاري راشد العفاسي',
      'asset': 'assets/audio/adhan/mishary.mp3',
    },
    {
      'id': 'abdulbasit',
      'name': 'عبد الباسط عبد الصمد',
      'asset': 'assets/audio/adhan/abdulbasit.mp3',
    },
    {
      'id': 'sudais',
      'name': 'عبد الرحمن السديس',
      'asset': 'assets/audio/adhan/sudais.mp3',
    },
  ];

  // ---------------------------------------------------------------------------
  // Voice preference
  // ---------------------------------------------------------------------------

  Future<String> getSelectedVoiceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_keySelectedVoice) ??
        prefs.getString(_legacyKeySelectedSound);
    id ??= 'makkah';
    if (id == 'madina') id = 'madinah';
    if (!_voiceIds.contains(id)) id = 'makkah';
    return id;
  }

  static final Set<String> _voiceIds =
      voices.map((v) => v['id']!).toSet();

  Future<void> saveSelectedVoiceId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _voiceIds.contains(id) ? id : 'makkah';
    await prefs.setString(_keySelectedVoice, normalized);
    await prefs.setString(_legacyKeySelectedSound, normalized);
  }

  Map<String, String> getVoiceById(String id) {
    return voices.firstWhere(
      (v) => v['id'] == id,
      orElse: () => voices.first,
    );
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> playAdhan({String? voiceId}) async {
    if (_isLoading) return;

    try {
      final id = voiceId ?? await getSelectedVoiceId();
      final voice = getVoiceById(id);
      final assetPath = voice['asset']!;
      final name = voice['name']!;

      _isLoading = true;

      if (_isPlaying) {
        await _player.stop();
        _isPlaying = false;
      }

      await _player.setAudioSource(
        AudioSource.asset(assetPath),
      );

      _isLoading = false;
      await _player.play();
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      debugPrint('AdhanAudioPlayerService: error playing adhan: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  void dispose() {
    _player.dispose();
  }
}
