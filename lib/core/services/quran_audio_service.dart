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

  // Play ayah audio using CDN
  Future<void> playAyah(int surahNumber, int ayahNumber, {Reciter? reciter}) async {
    try {
      reciter ??= await getSelectedReciter();
      
      // Calculate global ayah number
      final globalAyahNumber = await _getGlobalAyahNumber(surahNumber, ayahNumber);
      
      // Use Islamic Network CDN
      final audioUrl = 'https://cdn.islamic.network/quran/audio/128/${reciter.identifier}/$globalAyahNumber.mp3';
      
      debugPrint('Playing ayah audio: $audioUrl');
      debugPrint('Surah: $surahNumber, Ayah: $ayahNumber, Global: $globalAyahNumber');
      
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

  // Calculate global ayah number (1-6236)
  Future<int> _getGlobalAyahNumber(int surahNumber, int ayahInSurah) async {
    // Ayah counts for each surah (1-114)
    final ayahCounts = [
      7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99,
      128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
      34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37,
      35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
      14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40,
      31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
      15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9,
      5, 4, 7, 3, 6, 3, 5, 4, 5, 6
    ];

    int globalNumber = ayahInSurah;
    for (int i = 0; i < surahNumber - 1; i++) {
      globalNumber += ayahCounts[i];
    }
    
    return globalNumber;
  }

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}
