import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/models/surah_full_model.dart';
import '../../data/repo/surah_full_service.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/common/widgets/default_app_bar.dart';
import '../../../../../core/utils/spacing.dart';

class SurahFullAudioScreen extends StatefulWidget {
  const SurahFullAudioScreen({super.key});
  static const String routeName = '/surah-full-audio';

  @override
  State<SurahFullAudioScreen> createState() => _SurahFullAudioScreenState();
}

class _SurahFullAudioScreenState extends State<SurahFullAudioScreen> {
  SurahFullModel? _surahData;
  bool _isLoading = false;
  bool _isLoadingAudio = false;
  String? _errorMessage;
  String _selectedReciter = 'ar.alafasy';
  int _selectedSurahId = 1;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  int? _currentPlayingAyah;
  
  // أسماء السور الـ 114
  static const List<Map<String, dynamic>> surahNames = [
    {'id': 1, 'name': 'الفاتحة'},
    {'id': 2, 'name': 'البقرة'},
    {'id': 3, 'name': 'آل عمران'},
    {'id': 4, 'name': 'النساء'},
    {'id': 5, 'name': 'المائدة'},
    {'id': 6, 'name': 'الأنعام'},
    {'id': 7, 'name': 'الأعراف'},
    {'id': 8, 'name': 'الأنفال'},
    {'id': 9, 'name': 'التوبة'},
    {'id': 10, 'name': 'يونس'},
    {'id': 11, 'name': 'هود'},
    {'id': 12, 'name': 'يوسف'},
    {'id': 13, 'name': 'الرعد'},
    {'id': 14, 'name': 'إبراهيم'},
    {'id': 15, 'name': 'الحجر'},
    {'id': 16, 'name': 'النحل'},
    {'id': 17, 'name': 'الإسراء'},
    {'id': 18, 'name': 'الكهف'},
    {'id': 19, 'name': 'مريم'},
    {'id': 20, 'name': 'طه'},
    {'id': 21, 'name': 'الأنبياء'},
    {'id': 22, 'name': 'الحج'},
    {'id': 23, 'name': 'المؤمنون'},
    {'id': 24, 'name': 'النور'},
    {'id': 25, 'name': 'الفرقان'},
    {'id': 26, 'name': 'الشعراء'},
    {'id': 27, 'name': 'النمل'},
    {'id': 28, 'name': 'القصص'},
    {'id': 29, 'name': 'العنكبوت'},
    {'id': 30, 'name': 'الروم'},
    {'id': 31, 'name': 'لقمان'},
    {'id': 32, 'name': 'السجدة'},
    {'id': 33, 'name': 'الأحزاب'},
    {'id': 34, 'name': 'سبأ'},
    {'id': 35, 'name': 'فاطر'},
    {'id': 36, 'name': 'يس'},
    {'id': 37, 'name': 'الصافات'},
    {'id': 38, 'name': 'ص'},
    {'id': 39, 'name': 'الزمر'},
    {'id': 40, 'name': 'غافر'},
    {'id': 41, 'name': 'فصلت'},
    {'id': 42, 'name': 'الشورى'},
    {'id': 43, 'name': 'الزخرف'},
    {'id': 44, 'name': 'الدخان'},
    {'id': 45, 'name': 'الجاثية'},
    {'id': 46, 'name': 'الأحقاف'},
    {'id': 47, 'name': 'محمد'},
    {'id': 48, 'name': 'الفتح'},
    {'id': 49, 'name': 'الحجرات'},
    {'id': 50, 'name': 'ق'},
    {'id': 51, 'name': 'الذاريات'},
    {'id': 52, 'name': 'الطور'},
    {'id': 53, 'name': 'النجم'},
    {'id': 54, 'name': 'القمر'},
    {'id': 55, 'name': 'الرحمن'},
    {'id': 56, 'name': 'الواقعة'},
    {'id': 57, 'name': 'الحديد'},
    {'id': 58, 'name': 'المجادلة'},
    {'id': 59, 'name': 'الحشر'},
    {'id': 60, 'name': 'الممتحنة'},
    {'id': 61, 'name': 'الصف'},
    {'id': 62, 'name': 'الجمعة'},
    {'id': 63, 'name': 'المنافقون'},
    {'id': 64, 'name': 'التغابن'},
    {'id': 65, 'name': 'الطلاق'},
    {'id': 66, 'name': 'التحريم'},
    {'id': 67, 'name': 'الملك'},
    {'id': 68, 'name': 'القلم'},
    {'id': 69, 'name': 'الحاقة'},
    {'id': 70, 'name': 'المعارج'},
    {'id': 71, 'name': 'نوح'},
    {'id': 72, 'name': 'الجن'},
    {'id': 73, 'name': 'المزمل'},
    {'id': 74, 'name': 'المدثر'},
    {'id': 75, 'name': 'القيامة'},
    {'id': 76, 'name': 'الإنسان'},
    {'id': 77, 'name': 'المرسلات'},
    {'id': 78, 'name': 'النبأ'},
    {'id': 79, 'name': 'النازعات'},
    {'id': 80, 'name': 'عبس'},
    {'id': 81, 'name': 'التكوير'},
    {'id': 82, 'name': 'الإنفطار'},
    {'id': 83, 'name': 'المطففين'},
    {'id': 84, 'name': 'الإنشقاق'},
    {'id': 85, 'name': 'البروج'},
    {'id': 86, 'name': 'الطارق'},
    {'id': 87, 'name': 'الأعلى'},
    {'id': 88, 'name': 'الغاشية'},
    {'id': 89, 'name': 'الفجر'},
    {'id': 90, 'name': 'البلد'},
    {'id': 91, 'name': 'الشمس'},
    {'id': 92, 'name': 'الليل'},
    {'id': 93, 'name': 'الضحى'},
    {'id': 94, 'name': 'الشرح'},
    {'id': 95, 'name': 'التين'},
    {'id': 96, 'name': 'العلق'},
    {'id': 97, 'name': 'القدر'},
    {'id': 98, 'name': 'البينة'},
    {'id': 99, 'name': 'الزلزلة'},
    {'id': 100, 'name': 'العاديات'},
    {'id': 101, 'name': 'القارعة'},
    {'id': 102, 'name': 'التكاثر'},
    {'id': 103, 'name': 'العصر'},
    {'id': 104, 'name': 'الهمزة'},
    {'id': 105, 'name': 'الفيل'},
    {'id': 106, 'name': 'قريش'},
    {'id': 107, 'name': 'الماعون'},
    {'id': 108, 'name': 'الكوثر'},
    {'id': 109, 'name': 'الكافرون'},
    {'id': 110, 'name': 'النصر'},
    {'id': 111, 'name': 'المسد'},
    {'id': 112, 'name': 'الإخلاص'},
    {'id': 113, 'name': 'الفلق'},
    {'id': 114, 'name': 'الناس'},
  ];

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
          _currentPlayingAyah = null;
        });
      }
    });
  }

  Future<void> _loadSurahData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await SurahFullService.getFullSurah(
        surahId: _selectedSurahId,
        reciter: _selectedReciter,
        audio: true,
      );
      
      setState(() {
        _surahData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _playSurahAudio() async {
    if (_surahData?.audioUrl == null) return;

    try {
      setState(() {
        _isLoadingAudio = true;
      });

      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isLoadingAudio = false;
        });
      } else {
        debugPrint('Playing Surah audio from URL: ${_surahData!.audioUrl}');
        
        // Configure audio player for iOS
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.setVolume(1.0);
        
        if (_currentPosition == Duration.zero) {
          await _audioPlayer.play(UrlSource(_surahData!.audioUrl!));
        } else {
          await _audioPlayer.resume();
        }
        setState(() {
          _isLoadingAudio = false;
        });
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      setState(() {
        _isLoadingAudio = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الصوت. تحقق من الاتصال بالإنترنت'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _playAyahAudio(int ayahIndex) async {
    final ayah = _surahData?.ayahs[ayahIndex];
    if (ayah?.audio == null) return;

    try {
      setState(() {
        _isLoadingAudio = true;
      });

      debugPrint('Playing Ayah audio from URL: ${ayah!.audio}');
      
      // Configure audio player for iOS
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);
      
      await _audioPlayer.play(UrlSource(ayah.audio!));
      
      setState(() {
        _currentPlayingAyah = ayahIndex;
        _isLoadingAudio = false;
      });
    } catch (e) {
      debugPrint('Error playing ayah audio: $e');
      setState(() {
        _isLoadingAudio = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الآية. تحقق من الاتصال بالإنترنت'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const DefaultAppBar(
                    title: 'قراءة السورة كاملة',
                    icon: Icons.arrow_back,
                  ),
                  verticalSpace(12),
                  
                  // Surah selector
                  _buildSurahSelector(),
                  
                  verticalSpace(12),
                  
                  // Reciter selector
                  _buildReciterSelector(),
                  
                  verticalSpace(12),
                  
                  // Load button
                  if (_surahData == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loadSurahData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'تحميل السورة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(),
            ),

            // Audio player (shown when surah is loaded)
            if (_surahData != null) _buildAudioPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book, color: AppColors.primaryColor, size: 20),
          horizontalSpace(12),
          Text(
            'اختر السورة:',
            style: TextStyles.font16PrimaryText.copyWith(
              fontFamily: FontFamilyHelper.fontFamily1,
              fontWeight: FontWeight.bold,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedSurahId,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                style: TextStyles.font16PrimaryText.copyWith(
                  fontFamily: FontFamilyHelper.fontFamily1,
                  color: AppColors.primaryColor,
                ),
                items: surahNames.map((surah) {
                  return DropdownMenuItem(
                    value: surah['id'] as int,
                    child: Text('${surah['id']}. ${surah['name']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSurahId = value;
                      _surahData = null;
                      _audioPlayer.stop();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReciterSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: AppColors.primaryColor, size: 20),
          horizontalSpace(12),
          Text(
            'القارئ:',
            style: TextStyles.font16PrimaryText.copyWith(
              fontFamily: FontFamilyHelper.fontFamily1,
              fontWeight: FontWeight.bold,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReciter,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                style: TextStyles.font16PrimaryText.copyWith(
                  fontFamily: FontFamilyHelper.fontFamily1,
                  color: AppColors.primaryColor,
                ),
                items: SurahFullService.availableReciters.map((reciter) {
                  return DropdownMenuItem(
                    value: reciter.id,
                    child: Text(reciter.nameArabic),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedReciter = value;
                      _surahData = null;
                      _audioPlayer.stop();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_surahData == null) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Surah header card
        _buildSurahHeaderCard(),
        
        verticalSpace(16),
        
        // Ayahs list
        Text(
          'الآيات',
          style: TextStyles.font20PrimaryText.copyWith(
            fontFamily: FontFamilyHelper.fontFamily1,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        verticalSpace(12),
        
        ...List.generate(_surahData!.ayahs.length, (index) {
          final ayah = _surahData!.ayahs[index];
          return FadeInUp(
            delay: Duration(milliseconds: 30 * index),
            duration: const Duration(milliseconds: 400),
            child: _buildAyahCard(ayah, index),
          );
        }),
      ],
    );
  }

  Widget _buildSurahHeaderCard() {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              _surahData!.name,
              style: TextStyles.font24WhiteText.copyWith(
                fontFamily: FontFamilyHelper.fontFamily1,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            if (_surahData!.nameEnglish != null) ...[
              verticalSpace(6),
              Text(
                _surahData!.nameEnglish!,
                style: TextStyles.font16PrimaryText.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
            verticalSpace(12),
            Divider(color: Colors.white.withOpacity(0.3)),
            verticalSpace(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.list_alt,
                  '${_surahData!.ayahs.length} آية',
                ),
                _buildInfoItem(
                  Icons.person,
                  SurahFullService.getReciterNameArabic(_selectedReciter),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        horizontalSpace(6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAyahCard(AyahWithAudioModel ayah, int index) {
    final isPlaying = _currentPlayingAyah == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying
              ? AppColors.primaryColor
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ayah number
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyles.font16PrimaryText.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Play button
              if (ayah.audio != null)
                _isLoadingAudio && _currentPlayingAyah == index
                    ? SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : IconButton(
                        onPressed: () => _playAyahAudio(index),
                        icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                          color: AppColors.primaryColor,
                          size: 32,
                        ),
                      ),
            ],
          ),
          
          verticalSpace(12),
          
          // Ayah text
          Text(
            ayah.text,
            style: TextStyles.font18PrimaryText.copyWith(
              fontFamily: 'Amiri Quran',
              height: 1.8,
              color: Colors.black87,
              fontSize: 20,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: TextStyles.font14PrimaryText.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  max: _totalDuration.inSeconds.toDouble() > 0
                      ? _totalDuration.inSeconds.toDouble()
                      : 1,
                  activeColor: AppColors.primaryColor,
                  inactiveColor: Colors.grey[300],
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyles.font14PrimaryText.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          verticalSpace(8),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause button
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoadingAudio
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        onPressed: _playSurahAudio,
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
              ),
            ],
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
          Text(
            'جاري تحميل السورة...',
            style: TextStyles.font16PrimaryText.copyWith(
              color: Colors.grey[600],
              fontFamily: FontFamilyHelper.fontFamily1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            verticalSpace(16),
            Text(
              _errorMessage ?? 'حدث خطأ',
              style: TextStyles.font16PrimaryText.copyWith(
                color: Colors.grey[600],
                fontFamily: FontFamilyHelper.fontFamily1,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace(24),
            ElevatedButton(
              onPressed: _loadSurahData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headphones,
              size: 100,
              color: Colors.grey[300],
            ),
            verticalSpace(24),
            Text(
              'اختر السورة والقارئ',
              style: TextStyles.font20PrimaryText.copyWith(
                color: Colors.grey[600],
                fontFamily: FontFamilyHelper.fontFamily1,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpace(12),
            Text(
              'اضغط على زر "تحميل السورة" للبدء',
              style: TextStyles.font16PrimaryText.copyWith(
                color: Colors.grey[500],
                fontFamily: FontFamilyHelper.fontFamily1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

