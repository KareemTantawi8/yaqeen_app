import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../core/services/quran_audio_service.dart';
import '../../../../../core/services/quran_reading_service.dart';
import '../../../../../core/services/reading_progress_notifier.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/ayah_model.dart';
import '../../../data/models/reciter_model.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repo/quran_data_loader.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah surah;
  final Reciter reciter;

  const QuranReaderScreen({
    super.key,
    required this.surah,
    required this.reciter,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final QuranAudioService _audioService = QuranAudioService();
  
  List<Ayah> _ayahs = [];
  bool _isLoading = false;
  String? _error;
  bool _showScrollToTop = false;
  double _fontSize = 24.0;

  // For full surah playback
  final AudioPlayer _fullSurahPlayer = AudioPlayer();
  bool _isPlayingFullSurah = false;
  int? _currentPlayingAyah;

  @override
  void initState() {
    super.initState();
    _loadAyahs();
    _setupScrollListener();
    _setupAudioListener();
    _setupFullSurahListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final show = _scrollController.offset > 500;
      if (show != _showScrollToTop) {
        setState(() => _showScrollToTop = show);
      }
    });
  }

  void _setupAudioListener() {
    _audioService.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          if (state.playing) {
            _currentPlayingAyah = _audioService.currentAyahNumber;
          } else {
            _currentPlayingAyah = null;
          }
        });
      }
    });
  }

  void _setupFullSurahListener() {
    _fullSurahPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingFullSurah = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlayingFullSurah = false;
          }
        });
      }
    });
  }

  Future<void> _loadAyahs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final surahData = await QuranDataLoader.getSurahDetails(widget.surah.number);
      final ayahsList = surahData['ayahs'] as List<dynamic>;
      
      if (mounted) {
        setState(() {
          _ayahs = ayahsList.map((json) => Ayah.fromJson(json as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playFullSurah() async {
    try {
      if (_isPlayingFullSurah) {
        await _fullSurahPlayer.pause();
        setState(() => _isPlayingFullSurah = false);
      } else {
        // Stop any ayah playback
        await _audioService.stop();
        
        // Construct full surah audio URL
        final audioUrl = 'https://cdn.islamic.network/quran/audio-surah/128/${widget.reciter.identifier}/${widget.surah.number}.mp3';
        debugPrint('Playing full surah audio: $audioUrl');
        
        await _fullSurahPlayer.setUrl(audioUrl);
        await _fullSurahPlayer.play();
        setState(() => _isPlayingFullSurah = true);
      }
    } catch (e) {
      debugPrint('Error playing full surah: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تشغيل السورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playAyah(Ayah ayah) async {
    try {
      // Stop full surah if playing
      if (_isPlayingFullSurah) {
        await _fullSurahPlayer.stop();
        setState(() => _isPlayingFullSurah = false);
      }

      if (_audioService.isAyahPlaying(widget.surah.number, ayah.numberInSurah)) {
        await _audioService.pause();
        setState(() => _currentPlayingAyah = null);
      } else {
        await _audioService.playAyah(
          widget.surah.number,
          ayah.numberInSurah,
          reciter: widget.reciter,
        );
        setState(() => _currentPlayingAyah = ayah.numberInSurah);
      }
    } catch (e) {
      debugPrint('Error playing ayah: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تشغيل الآية: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyAyah(Ayah ayah) async {
    await Clipboard.setData(ClipboardData(text: ayah.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              horizontalSpace(8),
              const Text(
                'تم نسخ الآية',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleBookmark(Ayah ayah) async {
    final isBookmarked = await QuranReadingService.isBookmarked(
      widget.surah.number,
      ayah.numberInSurah,
    );

    if (isBookmarked) {
      await QuranReadingService.removeBookmark(
        widget.surah.number,
        ayah.numberInSurah,
      );
    } else {
      final bookmark = BookmarkedAyah(
        surahNumber: widget.surah.number,
        surahName: widget.surah.name,
        ayahNumber: ayah.numberInSurah,
        ayahText: ayah.text,
        bookmarkedAt: DateTime.now(),
      );
      await QuranReadingService.addBookmark(bookmark);
    }

    // Save progress
    final progress = ReadingProgress(
      surahNumber: widget.surah.number,
      surahName: widget.surah.name,
      surahEnglishName: widget.surah.englishName,
      ayahNumber: ayah.numberInSurah,
      ayahText: ayah.text,
      totalAyahs: widget.surah.numberOfAyahs,
      lastRead: DateTime.now(),
    );
    await QuranReadingService.saveReadingProgress(progress);

    // Notify listeners
    final savedProgress = await QuranReadingService.getReadingProgress();
    if (savedProgress != null) {
      ReadingProgressNotifier().updateProgress(savedProgress);
    }

    setState(() {});
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'حجم الخط',
          style: TextStyle(fontFamily: 'Tajawal'),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontFamily: 'Amiri Quran',
                    fontSize: _fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpace(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_fontSize.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _fontSize,
                        min: 16,
                        max: 40,
                        divisions: 24,
                        activeColor: AppColors.primaryColor,
                        onChanged: (value) {
                          setDialogState(() => _fontSize = value);
                          setState(() => _fontSize = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullSurahPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildReciterBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                      ? _buildErrorState()
                      : _buildAyahsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withAlpha(204),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.surah.name,
                  style: const TextStyle(
                    fontFamily: 'Amiri Quran',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${widget.surah.englishName} • ${widget.surah.numberOfAyahs} آية',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showFontSizeDialog,
            icon: const Icon(Icons.format_size, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReciterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withAlpha(178),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
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
                const Text(
                  'بصوت',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.reciter.name,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _playFullSurah,
            icon: Icon(
              _isPlayingFullSurah ? Icons.pause_circle : Icons.play_circle,
              size: 36,
            ),
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          verticalSpace(16),
          const Text(
            'جاري تحميل الآيات...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          verticalSpace(16),
          const Text(
            'حدث خطأ في التحميل',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              color: Colors.red,
            ),
          ),
          verticalSpace(8),
          ElevatedButton.icon(
            onPressed: _loadAyahs,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _ayahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0 && widget.surah.number != 1 && widget.surah.number != 9) {
          return _buildBismillah();
        }
        
        final ayahIndex = (widget.surah.number != 1 && widget.surah.number != 9) 
            ? index - 1 
            : index;
            
        if (ayahIndex >= _ayahs.length) return const SizedBox.shrink();
        
        final ayah = _ayahs[ayahIndex];
        return _buildAyahCard(ayah);
      },
    );
  }

  Widget _buildBismillah() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryColor.withAlpha(25),
            AppColors.primaryColor.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withAlpha(76),
          width: 2,
        ),
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        style: TextStyle(
          fontFamily: 'Amiri Quran',
          fontSize: _fontSize + 4,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          height: 2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAyahCard(Ayah ayah) {
    final isCurrentlyPlaying = _currentPlayingAyah == ayah.numberInSurah;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying 
            ? AppColors.primaryColor.withAlpha(13)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentlyPlaying
              ? AppColors.primaryColor.withAlpha(128)
              : Colors.grey.shade200,
          width: isCurrentlyPlaying ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentlyPlaying
                ? AppColors.primaryColor.withAlpha(51)
                : Colors.grey.withAlpha(25),
            blurRadius: isCurrentlyPlaying ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ayah Text
            RichText(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                text: ayah.text,
                style: TextStyle(
                  fontFamily: 'Amiri Quran',
                  fontSize: _fontSize,
                  height: 2,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: ' ﴿${ayah.numberInSurah}﴾',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            verticalSpace(12),
            const Divider(),
            verticalSpace(8),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                  label: isCurrentlyPlaying ? 'إيقاف' : 'تشغيل',
                  onTap: () => _playAyah(ayah),
                  color: isCurrentlyPlaying ? Colors.orange : AppColors.primaryColor,
                ),
                _buildActionButton(
                  icon: Icons.copy,
                  label: 'نسخ',
                  onTap: () => _copyAyah(ayah),
                  color: Colors.blue,
                ),
                FutureBuilder<bool>(
                  future: QuranReadingService.isBookmarked(
                    widget.surah.number,
                    ayah.numberInSurah,
                  ),
                  builder: (context, snapshot) {
                    final bookmarked = snapshot.data ?? false;
                    return _buildActionButton(
                      icon: bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      label: bookmarked ? 'محفوظ' : 'حفظ',
                      onTap: () => _toggleBookmark(ayah),
                      color: bookmarked ? Colors.amber : Colors.grey,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            verticalSpace(4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
