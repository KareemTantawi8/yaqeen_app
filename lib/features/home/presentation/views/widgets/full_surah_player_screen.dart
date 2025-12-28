import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/reciter_model.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repo/quran_data_loader.dart';

class FullSurahPlayerScreen extends StatefulWidget {
  const FullSurahPlayerScreen({super.key});

  @override
  State<FullSurahPlayerScreen> createState() => _FullSurahPlayerScreenState();
}

class _FullSurahPlayerScreenState extends State<FullSurahPlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Surah? _currentPlayingSurah;
  Reciter _selectedReciter = RecitersList.popular[0]; // Default reciter
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  bool _showPlayer = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
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
      }
    });
  }

  Future<void> _playSurah(Surah surah) async {
    try {
      final bitrate = '128';
      final edition = _selectedReciter.identifier;
      final surahNumber = surah.number.toString();

      final audioUrl =
          'https://cdn.islamic.network/quran/audio-surah/$bitrate/$edition/$surahNumber.mp3';

      setState(() {
        _isLoading = true;
        _currentPlayingSurah = surah;
        _showPlayer = true;
      });

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      debugPrint('✅ Playing ${surah.englishName}');
    } catch (e) {
      debugPrint('❌ Error playing surah: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'فشل تشغيل السورة. تحقق من الاتصال بالإنترنت',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _playSurah(surah),
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _stopPlayback() {
    _audioPlayer.stop();
    setState(() {
      _showPlayer = false;
      _currentPlayingSurah = null;
    });
  }

  void _showReciterSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            verticalSpace(12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            verticalSpace(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.mic, color: AppColors.primaryColor, size: 28),
                  horizontalSpace(12),
                  Text(
                    'اختر القارئ',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: RecitersList.popular.length,
                itemBuilder: (context, index) {
                  final reciter = RecitersList.popular[index];
                  final isSelected = reciter.identifier == _selectedReciter.identifier;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedReciter = reciter;
                        });
                        Navigator.pop(context);
                        // Replay current surah with new reciter if playing
                        if (_currentPlayingSurah != null) {
                          _playSurah(_currentPlayingSurah!);
                        }
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.3)
                              : AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: isSelected ? Colors.white : AppColors.primaryColor,
                        ),
                      ),
                      title: Text(
                        reciter.name,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isSelected ? Colors.white : const Color(0xFF1A2221),
                        ),
                      ),
                      subtitle: Text(
                        reciter.englishName,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.white)
                          : Icon(Icons.circle_outlined,
                              color: Colors.grey[400]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Header with Reciter Selector
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.85),
                      const Color(0xFF1A5F54),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        // Title and Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.queue_music,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            horizontalSpace(16),
                            const Text(
                              'تشغيل السور',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(20),

                        // Reciter Selector Button
                        InkWell(
                          onTap: _showReciterSelector,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                horizontalSpace(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'القارئ الحالي',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                          fontFamily: 'Tajawal',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      verticalSpace(2),
                                      Text(
                                        _selectedReciter.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Tajawal',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Surahs Grid
              Expanded(
                child: FutureBuilder<List<Surah>>(
                  future: QuranDataLoader.loadSurahs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryColor),
                            verticalSpace(16),
                            const Text(
                              'جاري تحميل السور...',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text(
                          'فشل تحميل السور',
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                        ),
                      );
                    }

                    final surahs = snapshot.data!;

                    return GridView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: _showPlayer ? 180 : 16,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 600 ? 3 : 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: surahs.length,
                      itemBuilder: (context, index) {
                        final surah = surahs[index];
                        final isCurrentlyPlaying =
                            _currentPlayingSurah?.number == surah.number;

                        return _buildSurahCard(
                          surah,
                          isCurrentlyPlaying,
                          screenWidth,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Player
          if (_showPlayer && _currentPlayingSurah != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFloatingPlayer(screenWidth),
            ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(Surah surah, bool isPlaying, double screenWidth) {
    final colors = [
      [const Color(0xFF2B7669), const Color(0xFF1A5F54)],
      [const Color(0xFF6B5B95), const Color(0xFF4A3F6B)],
      [const Color(0xFF00796B), const Color(0xFF004D40)],
      [const Color(0xFF5D4037), const Color(0xFF3E2723)],
      [const Color(0xFF1976D2), const Color(0xFF0D47A1)],
      [const Color(0xFF7B1FA2), const Color(0xFF4A148C)],
    ];

    final colorIndex = surah.number % colors.length;
    final gradient = colors[colorIndex];

    return InkWell(
      onTap: () => _playSurah(surah),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPlaying
                ? [AppColors.primaryColor, const Color(0xFF1A5F54)]
                : [gradient[0], gradient[1]],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isPlaying ? AppColors.primaryColor : gradient[0])
                  .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Surah Number Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Surah Names
                  Column(
                    children: [
                      Text(
                        surah.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Amiri Quran',
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(6),
                      Text(
                        surah.englishName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(4),
                      Text(
                        '${surah.numberOfAyahs} آيات',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Play Button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: isPlaying && _isPlaying
                        ? const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 28,
                          )
                        : const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ],
              ),
            ),

            // Playing indicator
            if (isPlaying)
              Positioned(
                top: 8,
                left: 8,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final animation = Tween<double>(begin: 0.3, end: 1.0)
                              .animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                delay,
                                delay + 0.4,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          );

                          return Container(
                            width: 3,
                            height: 12 * animation.value,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingPlayer(double screenWidth) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Album Art
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.audiotrack,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                horizontalSpace(16),

                // Surah Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPlayingSurah!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Amiri Quran',
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(4),
                      Text(
                        _selectedReciter.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Controls
                if (_isLoading)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 40,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: _stopPlayback,
                ),
              ],
            ),
          ),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble().clamp(1.0, double.infinity),
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
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
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
        ],
      ),
    );
  }
}

