import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/quran_audio_service.dart';
import '../../../../core/services/quran_reading_service.dart';
import '../../../../core/services/quran_tafsir_service.dart';
import '../../../../core/services/reading_progress_notifier.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/reciter_model.dart';
import '../../data/models/surah_model.dart';
import '../../data/repo/quran_data_loader.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyahNumber;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialAyahNumber,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  SurahDetail? surahDetail;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  Set<int> bookmarkedAyahs = {};
  final Map<int, GlobalKey> _ayahKeys = {};
  int? _currentVisibleAyah;
  double _fontSize = 24.0;
  final QuranAudioService _audioService = QuranAudioService();
  Reciter? _selectedReciter;

  @override
  void initState() {
    super.initState();
    _loadSurahDetails();
    _loadBookmarks();
    _loadSelectedReciter();
    _scrollController.addListener(_updateScrollProgress);
    
    // Listen to audio player state
    _audioService.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadSelectedReciter() async {
    final reciter = await _audioService.getSelectedReciter();
    if (mounted) {
      setState(() {
        _selectedReciter = reciter;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioService.stop();
    super.dispose();
  }

  void _showReciterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'اختر القارئ',
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: RecitersList.popular.length,
            itemBuilder: (context, index) {
              final reciter = RecitersList.popular[index];
              final isSelected = _selectedReciter?.identifier == reciter.identifier;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected 
                      ? AppColors.primaryColor 
                      : Colors.grey[200],
                  child: Icon(
                    isSelected ? Icons.check : Icons.person,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
                title: Text(
                  reciter.name,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryColor : null,
                  ),
                ),
                subtitle: Text(
                  reciter.englishName,
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () async {
                  await _audioService.saveSelectedReciter(reciter);
                  setState(() {
                    _selectedReciter = reciter;
                  });
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم اختيار القارئ: ${reciter.name}',
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                      backgroundColor: AppColors.primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إغلاق',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAyahAudio(Ayah ayah) async {
    try {
      if (_audioService.isAyahPlaying(widget.surah.number, ayah.numberInSurah)) {
        await _audioService.pause();
      } else {
        await _audioService.playAyah(
          widget.surah.number,
          ayah.numberInSurah,
          reciter: _selectedReciter,
        );
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تشغيل الصوت',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });

      // Save reading progress
      _saveReadingProgress();
    }
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await QuranReadingService.getBookmarks();
    if (mounted) {
      setState(() {
        bookmarkedAyahs = bookmarks
            .where((b) => b.surahNumber == widget.surah.number)
            .map((b) => b.ayahNumber)
            .toSet();
      });
    }
  }

  Future<void> _loadSurahDetails() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      final response = await QuranDataLoader.getSurahDetails(widget.surah.number);
      final detail = SurahDetail.fromJson(response);

      // Create keys for each ayah
      for (var ayah in detail.ayahs) {
        _ayahKeys[ayah.numberInSurah] = GlobalKey();
      }

      setState(() {
        surahDetail = detail;
        isLoading = false;
      });

      // Scroll to specific ayah if requested
      if (widget.initialAyahNumber != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyah(widget.initialAyahNumber!);
        });
      }
    } catch (e) {
      debugPrint('Failed to load surah details: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل السورة';
      });
    }
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  void _saveReadingProgress() {
    if (surahDetail != null && surahDetail!.ayahs.isNotEmpty) {
      // Find the first visible ayah
      int visibleAyahNumber = 1;
      
      for (var ayah in surahDetail!.ayahs) {
        final key = _ayahKeys[ayah.numberInSurah];
        if (key?.currentContext != null) {
          final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            if (position.dy >= 0 && position.dy < 300) {
              visibleAyahNumber = ayah.numberInSurah;
              break;
            }
          }
        }
      }

      if (_currentVisibleAyah != visibleAyahNumber) {
        _currentVisibleAyah = visibleAyahNumber;
        final ayah = surahDetail!.ayahs.firstWhere(
          (a) => a.numberInSurah == visibleAyahNumber,
          orElse: () => surahDetail!.ayahs.first,
        );

        final progress = ReadingProgress(
          surahNumber: widget.surah.number,
          surahName: widget.surah.name,
          surahEnglishName: widget.surah.englishName,
          ayahNumber: ayah.numberInSurah,
          ayahText: ayah.text.substring(0, ayah.text.length > 100 ? 100 : ayah.text.length),
          totalAyahs: widget.surah.numberOfAyahs,
          lastRead: DateTime.now(),
        );

        // Save and notify
        ReadingProgressNotifier().updateProgress(progress);
      }
    }
  }

  Future<void> _copyAyah(Ayah ayah) async {
    await Clipboard.setData(
      ClipboardData(text: '${ayah.text} [${widget.surah.name} - آية ${ayah.numberInSurah}]'),
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text(
                'تم نسخ الآية',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final ayah = surahDetail!.ayahs.firstWhere((a) => a.numberInSurah == ayahNumber);
    
    if (bookmarkedAyahs.contains(ayahNumber)) {
      await QuranReadingService.removeBookmark(widget.surah.number, ayahNumber);
      setState(() {
        bookmarkedAyahs.remove(ayahNumber);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إزالة العلامة المرجعية', style: TextStyle(fontFamily: 'Tajawal')),
            backgroundColor: Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await QuranReadingService.addBookmark(
        BookmarkedAyah(
          surahNumber: widget.surah.number,
          surahName: widget.surah.name,
          ayahNumber: ayahNumber,
          ayahText: ayah.text,
          bookmarkedAt: DateTime.now(),
        ),
      );
      setState(() {
        bookmarkedAyahs.add(ayahNumber);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.bookmark, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('تمت إضافة علامة مرجعية', style: TextStyle(fontFamily: 'Tajawal')),
              ],
            ),
            backgroundColor: AppColors.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _shareSurah() {
    if (surahDetail != null) {
      final text = surahDetail!.ayahs.map((ayah) => ayah.text).join('\n\n');
      Share.share(
        '${widget.surah.name}\n\n$text',
        subject: widget.surah.englishName,
      );
    }
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حجم الخط', style: TextStyle(fontFamily: 'Tajawal')),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مثال على النص',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontFamily: 'Amiri Quran',
                  ),
                ),
                Slider(
                  value: _fontSize,
                  min: 18.0,
                  max: 36.0,
                  divisions: 6,
                  label: _fontSize.round().toString(),
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setDialogState(() {
                      _fontSize = value;
                    });
                    setState(() {});
                  },
                ),
                Text(
                  'الحجم: ${_fontSize.round()}',
                  style: const TextStyle(fontFamily: 'Tajawal'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تم', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  void _showTafsirDialog(Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التفسير',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          Text(
                            '${widget.surah.name} - آية ${ayah.numberInSurah}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Tafsir content
              Expanded(
                child: _TafsirContent(
                  surahNumber: widget.surah.number,
                  ayahNumber: ayah.numberInSurah,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Modern App Bar
          _buildSliverAppBar(screenHeight),

          // Loading State
          if (isLoading)
            SliverFillRemaining(
              child: _buildLoadingState(),
            ),

          // Error State
          if (hasError && !isLoading)
            SliverFillRemaining(
              child: _buildErrorState(),
            ),

          // Content
          if (!isLoading && !hasError && surahDetail != null) ...[
            // Surah Info Card
            SliverToBoxAdapter(
              child: _buildSurahInfoCard(screenWidth),
            ),

            // Bismillah
            if (widget.surah.number != 1 && widget.surah.number != 9)
              SliverToBoxAdapter(
                child: _buildBismillah(),
              ),

            // Ayahs List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ayah = surahDetail!.ayahs[index];
                    return Container(
                      key: _ayahKeys[ayah.numberInSurah],
                      child: _buildAyahCard(ayah, index),
                    );
                  },
                  childCount: surahDetail!.ayahs.length,
                ),
              ),
            ),

            // Bottom Padding
            SliverToBoxAdapter(
              child: const SizedBox(height: 80),
            ),
          ],
        ],
      ),

      // Floating Action Button for quick scroll to top
      floatingActionButton: _scrollProgress > 0.1
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

  Widget _buildSliverAppBar(double screenHeight) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          onPressed: _showReciterDialog,
          tooltip: 'اختر القارئ',
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.text_fields, color: Colors.white, size: 20),
          ),
          onPressed: _showFontSizeDialog,
          tooltip: 'حجم الخط',
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 20),
          ),
          onPressed: _shareSurah,
          tooltip: 'مشاركة السورة',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: AnimatedOpacity(
          opacity: _scrollProgress > 0.3 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.surah.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Amiri Quran',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Surah name in center when expanded
              Center(
                child: AnimatedOpacity(
                  opacity: _scrollProgress < 0.3 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.surah.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontFamily: 'Amiri Quran',
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.surah.englishName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Decorative Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/mosque_image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Progress Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: _scrollProgress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahInfoCard(double screenWidth) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.surah.englishName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2221),
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    verticalSpace(4),
                    Text(
                      widget.surah.englishNameTranslation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'سورة ${widget.surah.number}',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(16),
          const Divider(height: 1),
          verticalSpace(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip(
                icon: Icons.menu_book,
                label: '${widget.surah.numberOfAyahs} آية',
              ),
              _buildInfoChip(
                icon: Icons.location_on,
                label: widget.surah.type,
              ),
              if (surahDetail != null)
                _buildInfoChip(
                  icon: Icons.book,
                  label: 'الجزء ${surahDetail!.ayahs.first.juz}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryColor,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'Amiri Quran',
            color: AppColors.primaryColor,
            height: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard(Ayah ayah, int index) {
    final isBookmarked = bookmarkedAyahs.contains(ayah.numberInSurah);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Audio play button
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _audioService.isAyahPlaying(widget.surah.number, ayah.numberInSurah)
                          ? AppColors.primaryColor
                          : AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _audioService.isAyahPlaying(widget.surah.number, ayah.numberInSurah)
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: _audioService.isAyahPlaying(widget.surah.number, ayah.numberInSurah)
                          ? Colors.white
                          : AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _toggleAyahAudio(ayah),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'تشغيل الصوت',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                  onPressed: () => _toggleBookmark(ayah.numberInSurah),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.copy_outlined,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                  onPressed: () => _copyAyah(ayah),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                  onPressed: () => _showTafsirDialog(ayah),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'التفسير',
                ),
              ],
            ),
          ),

          // Ayah Text
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              ayah.text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: _fontSize,
                fontFamily: 'Amiri Quran',
                color: const Color(0xFF1A2221),
                height: 2.0,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Ayah Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                _buildFooterInfo('الصفحة', ayah.page.toString()),
                const SizedBox(width: 16),
                _buildFooterInfo('الجزء', ayah.juz.toString()),
                if (ayah.sajda) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.airline_seat_recline_normal,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'سجدة',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryColor,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primaryColor,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
            'جاري تحميل السورة...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            verticalSpace(16),
            Text(
              errorMessage ?? 'حدث خطأ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            verticalSpace(24),
            ElevatedButton(
              onPressed: _loadSurahDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tafsir content widget
class _TafsirContent extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final ScrollController scrollController;

  const _TafsirContent({
    required this.surahNumber,
    required this.ayahNumber,
    required this.scrollController,
  });

  @override
  State<_TafsirContent> createState() => _TafsirContentState();
}

class _TafsirContentState extends State<_TafsirContent> {
  String? _selectedTafsir;
  Map<String, String?> _tafsirData = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTafsir = QuranTafsirService.availableTafsirs.keys.first;
    _loadTafsir();
  }

  Future<void> _loadTafsir() async {
    if (_selectedTafsir == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tafsirText = await QuranTafsirService.getVerseTafsir(
        tafsirIdentifier: _selectedTafsir!,
        surahNumber: widget.surahNumber,
        ayahNumber: widget.ayahNumber,
      );

      setState(() {
        _tafsirData[_selectedTafsir!] = tafsirText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل التفسير';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tafsir selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: QuranTafsirService.availableTafsirs.entries.map((entry) {
                final isSelected = _selectedTafsir == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      entry.value['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Tajawal',
                        color: isSelected ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTafsir = entry.key;
                        });
                        _loadTafsir();
                      }
                    },
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Tafsir content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : _tafsirData[_selectedTafsir] == null
                      ? Center(
                          child: Text(
                            'لا يوجد تفسير متاح',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView(
                          controller: widget.scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _tafsirData[_selectedTafsir] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                  height: 1.8,
                                  color: Color(0xFF1A2221),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
        ),
      ],
    );
  }
}

