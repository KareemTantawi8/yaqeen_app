import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/reciter_model.dart';
import '../../../data/models/surah_model.dart';

class SurahAudioPlayerScreen extends StatefulWidget {
  final Reciter reciter;
  final Surah surah;
  final List<Surah> allSurahs;

  const SurahAudioPlayerScreen({
    super.key,
    required this.reciter,
    required this.surah,
    required this.allSurahs,
  });

  @override
  State<SurahAudioPlayerScreen> createState() => _SurahAudioPlayerScreenState();
}

class _SurahAudioPlayerScreenState extends State<SurahAudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Surah _currentSurah;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surah;
    _setupAudioPlayer();
    _playSurah();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
          
          if (_isPlaying) {
            _animationController.repeat();
          } else {
            _animationController.stop();
          }
        });

        // Auto play next
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }
      }
    });
  }

  Future<void> _playSurah() async {
    try {
      // Use the exact CDN format that works in Postman
      // Format: https://cdn.islamic.network/quran/audio-surah/:bitrate/:edition/:number.mp3
      final bitrate = '128';
      final edition = widget.reciter.identifier; // Keep full identifier like 'ar.alafasy'
      final surahNumber = _currentSurah.number.toString(); // No padding needed
      
      final audioUrl =
          'https://cdn.islamic.network/quran/audio-surah/$bitrate/$edition/$surahNumber.mp3';

      debugPrint('========================================');
      debugPrint('🎵 Attempting to play audio:');
      debugPrint('Reciter: ${widget.reciter.name}');
      debugPrint('Identifier: $edition');
      debugPrint('Surah: ${_currentSurah.englishName} (${_currentSurah.number})');
      debugPrint('URL: $audioUrl');
      debugPrint('========================================');

      setState(() {
        _isLoading = true;
      });

      // Try to set the URL with error handling
      try {
        await _audioPlayer.setUrl(audioUrl);
        debugPrint('✅ Audio URL set successfully');
        await _audioPlayer.play();
        debugPrint('✅ Audio playback started');
      } catch (audioError) {
        debugPrint('❌ Audio player error: $audioError');
        
        // Try alternative URL format without the language prefix
        final alternativeEdition = edition.replaceAll('ar.', '');
        final alternativeUrl = 
            'https://cdn.islamic.network/quran/audio-surah/$bitrate/$alternativeEdition/$surahNumber.mp3';
        
        debugPrint('🔄 Trying alternative URL without ar. prefix:');
        debugPrint('URL: $alternativeUrl');
        
        try {
          await _audioPlayer.setUrl(alternativeUrl);
          debugPrint('✅ Alternative URL set successfully');
          await _audioPlayer.play();
          debugPrint('✅ Alternative audio playback started');
        } catch (altError) {
          debugPrint('❌ Alternative URL also failed: $altError');
          throw audioError; // Throw original error
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Fatal error playing surah: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'فشل تشغيل السورة',
                  style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'تحقق من الاتصال بالإنترنت',
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _playSurah(),
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _playNext() {
    final currentIndex = widget.allSurahs.indexWhere(
      (s) => s.number == _currentSurah.number,
    );
    if (currentIndex < widget.allSurahs.length - 1) {
      setState(() {
        _currentSurah = widget.allSurahs[currentIndex + 1];
      });
      _playSurah();
    }
  }

  void _playPrevious() {
    final currentIndex = widget.allSurahs.indexWhere(
      (s) => s.number == _currentSurah.number,
    );
    if (currentIndex > 0) {
      setState(() {
        _currentSurah = widget.allSurahs[currentIndex - 1];
      });
      _playSurah();
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        Text(
                          'القارئ',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.reciter.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.playlist_play,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        // Show playlist
                      },
                    ),
                  ],
                ),
              ),

              verticalSpace(screenHeight * 0.04),

              // Animated Album Art
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2 * 3.14159,
                    child: child,
                  );
                },
                child: Container(
                  width: screenWidth * 0.7,
                  height: screenWidth * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.7),
                        const Color(0xFF1A5F54),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: screenWidth * 0.68,
                        height: screenWidth * 0.68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      // Inner ring
                      Container(
                        width: screenWidth * 0.5,
                        height: screenWidth * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.audiotrack,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      // Center dot
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              verticalSpace(screenHeight * 0.06),

              // Surah Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      _currentSurah.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontFamily: 'Amiri Quran',
                        color: Color(0xFF1A2221),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    verticalSpace(8),
                    Text(
                      _currentSurah.englishName,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    verticalSpace(4),
                    Text(
                      '${_currentSurah.type} • ${_currentSurah.numberOfAyahs} آيات',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor: AppColors.primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: AppColors.primaryColor,
                        overlayColor: AppColors.primaryColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds
                            .toDouble()
                            .clamp(1.0, double.infinity),
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              verticalSpace(32),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 32,
                        ),
                        color: AppColors.primaryColor,
                        onPressed: _playPrevious,
                      ),
                    ),

                    // Play/Pause button
                    _isLoading
                        ? Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 40,
                              ),
                              color: Colors.white,
                              onPressed: _togglePlayPause,
                            ),
                          ),

                    // Next button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          size: 32,
                        ),
                        color: AppColors.primaryColor,
                        onPressed: _playNext,
                      ),
                    ),
                  ],
                ),
              ),

              verticalSpace(screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

