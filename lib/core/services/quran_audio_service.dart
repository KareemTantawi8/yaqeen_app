import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/data/models/reciter_model.dart';

class QuranAudioService {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;
  QuranAudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _keySelectedReciter = 'selected_reciter';
  
  // Currently playing ayah info
  int? _currentSurahNumber;
  int? _currentAyahNumber;
  bool _isPlaying = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  int? get currentSurahNumber => _currentSurahNumber;
  int? get currentAyahNumber => _currentAyahNumber;

  // Get saved reciter or default
  Future<Reciter> getSelectedReciter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reciterJson = prefs.getString(_keySelectedReciter);
      
      if (reciterJson != null) {
        final json = jsonDecode(reciterJson) as Map<String, dynamic>;
        return Reciter.fromJson(json);
      }
      
      // Default reciter
      return RecitersList.popular[0];
    } catch (e) {
      debugPrint('Error getting selected reciter: $e');
      return RecitersList.popular[0];
    }
  }

  // Save selected reciter
  Future<void> saveSelectedReciter(Reciter reciter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(reciter.toJson());
      await prefs.setString(_keySelectedReciter, jsonString);
    } catch (e) {
      debugPrint('Error saving selected reciter: $e');
    }
  }

  // Play ayah audio using everyayah.com API
  Future<void> playAyah(int surahNumber, int ayahNumber, {Reciter? reciter}) async {
    try {
      reciter ??= await getSelectedReciter();
      
      // Format: https://everyayah.com/data/{reader_identifier}/{surah_id}{verse_id}.mp3
      // Surah and verse IDs are zero-padded to 3 digits
      final surahId = surahNumber.toString().padLeft(3, '0');
      final verseId = ayahNumber.toString().padLeft(3, '0');
      
      // Use everyayah.com API
      final audioUrl = 'https://everyayah.com/data/${reciter.identifier}/$surahId$verseId.mp3';
      
      debugPrint('Playing ayah audio: $audioUrl');
      debugPrint('Surah: $surahNumber, Ayah: $ayahNumber');
      
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      
      _currentSurahNumber = surahNumber;
      _currentAyahNumber = ayahNumber;
      _isPlaying = true;

      // Listen to completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _currentSurahNumber = null;
          _currentAyahNumber = null;
        }
      });
    } catch (e) {
      debugPrint('Error playing ayah: $e');
      _isPlaying = false;
      throw Exception('Failed to play audio: $e');
    }
  }

  // Pause audio
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  // Resume audio
  Future<void> resume() async {
    await _audioPlayer.play();
    _isPlaying = true;
  }

  // Stop audio
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentSurahNumber = null;
    _currentAyahNumber = null;
  }

  // Check if specific ayah is playing
  bool isAyahPlaying(int surahNumber, int ayahNumber) {
    return _isPlaying && 
           _currentSurahNumber == surahNumber && 
           _currentAyahNumber == ayahNumber;
  }

  // Get audio URL for ayah (for use in other services)
  String getAyahAudioUrl(int surahNumber, int ayahNumber, Reciter reciter) {
    final surahId = surahNumber.toString().padLeft(3, '0');
    final verseId = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/${reciter.identifier}/$surahId$verseId.mp3';
  }

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}
