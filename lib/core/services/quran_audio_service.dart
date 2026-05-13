import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/data/models/reciter_model.dart';

class QuranAudioService {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;

  QuranAudioService._internal() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentSurahNumber = null;
        _currentAyahNumber = null;
      } else {
        _isPlaying = state.playing;
      }
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _keySelectedReciter = 'selected_reciter';

  int? _currentSurahNumber;
  int? _currentAyahNumber;
  bool _isPlaying = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  int? get currentSurahNumber => _currentSurahNumber;
  int? get currentAyahNumber => _currentAyahNumber;

  Future<Reciter> getSelectedReciter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reciterJson = prefs.getString(_keySelectedReciter);
      if (reciterJson != null) {
        final json = jsonDecode(reciterJson) as Map<String, dynamic>;
        return Reciter.fromJson(json);
      }
      return RecitersList.popular[0];
    } catch (e) {
      debugPrint('Error getting selected reciter: $e');
      return RecitersList.popular[0];
    }
  }

  Future<void> saveSelectedReciter(Reciter reciter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedReciter, jsonEncode(reciter.toJson()));
    } catch (e) {
      debugPrint('Error saving selected reciter: $e');
    }
  }

  Future<void> playAyah(int surahNumber, int ayahNumber, {Reciter? reciter}) async {
    reciter ??= await getSelectedReciter();

    final surahId = surahNumber.toString().padLeft(3, '0');
    final verseId = ayahNumber.toString().padLeft(3, '0');
    final audioUrl =
        'https://everyayah.com/data/${reciter.identifier}/$surahId$verseId.mp3';

    // Set synchronously before any await — isAyahPlaying() returns true instantly
    _currentSurahNumber = surahNumber;
    _currentAyahNumber = ayahNumber;
    _isPlaying = true;

    debugPrint('Playing ayah: $audioUrl');

    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: audioUrl,
            title: 'آية $ayahNumber',
            album: 'سورة $surahNumber',
            artist: reciter.name,
          ),
        ),
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing ayah: $e');
      _isPlaying = false;
      _currentSurahNumber = null;
      _currentAyahNumber = null;
      rethrow;
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentSurahNumber = null;
    _currentAyahNumber = null;
  }

  bool isAyahPlaying(int surahNumber, int ayahNumber) {
    return _isPlaying &&
        _currentSurahNumber == surahNumber &&
        _currentAyahNumber == ayahNumber;
  }

  String getAyahAudioUrl(int surahNumber, int ayahNumber, Reciter reciter) {
    final surahId = surahNumber.toString().padLeft(3, '0');
    final verseId = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/${reciter.identifier}/$surahId$verseId.mp3';
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
