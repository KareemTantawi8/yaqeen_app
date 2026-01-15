import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yaqeen_app/core/services/quran_com_api_service.dart';
import 'package:yaqeen_app/core/services/quran_word_pronunciation_service.dart';
import 'package:yaqeen_app/core/services/quran_audio_service.dart';
import 'package:yaqeen_app/core/services/quran_timing_data_service.dart';
import 'package:yaqeen_app/core/services/quran_tafsir_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/styles/fonts/font_family_helper.dart';
import 'package:yaqeen_app/core/styles/fonts/font_styles.dart';
import 'package:yaqeen_app/core/common/widgets/default_app_bar.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/home/data/models/reciter_model.dart';
import 'package:yaqeen_app/features/home/data/repo/quran_page_service.dart';

/// New Quran Page View Screen using Quran.com API
/// Replaces old implementation with new API from Postman collection
class QuranPageViewScreen extends StatefulWidget {
  final int initialPage;
  
  const QuranPageViewScreen({
    super.key,
    this.initialPage = 1,
  });

  static const String routeName = '/quran-page-view';

  @override
  State<QuranPageViewScreen> createState() => _QuranPageViewScreenState();
}

class _QuranPageViewScreenState extends State<QuranPageViewScreen> {
  int _currentPage = 1;
  Map<String, dynamic>? _pageData;
  bool _isLoading = false;
  String? _errorMessage;
  Reciter? _selectedReciter;
  final AudioPlayer _wordAudioPlayer = AudioPlayer();
  Map<String, bool> _highlightedWords = {};
  Map<String, dynamic>? _timingData;
  bool _isWordByWordMode = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _loadReciter();
    _loadPage(_currentPage);
  }

  @override
  void dispose() {
    _wordAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadReciter() async {
    final audioService = QuranAudioService();
    final reciter = await audioService.getSelectedReciter();
    setState(() {
      _selectedReciter = reciter;
    });
    _loadTimingData(reciter);
  }

  Future<void> _loadTimingData(Reciter reciter) async {
    try {
      final timing = await QuranTimingDataService.getTimingData(reciter);
      setState(() {
        _timingData = timing;
      });
    } catch (e) {
      debugPrint('Error loading timing data: $e');
    }
  }

  Future<void> _loadPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = pageNumber;
    });

    try {
      final data = await QuranPageService.getPageVerses(pageNumber);
      setState(() {
        _pageData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل الصفحة: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _playWordPronunciation({
    required int surahNumber,
    required int verseNumber,
    required int wordPosition,
  }) async {
    try {
      final url = QuranWordPronunciationService.getWordPronunciationUrlSimple(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        wordPosition: wordPosition,
      );

      final wordKey = '$surahNumber:$verseNumber:$wordPosition';
      setState(() {
        _highlightedWords[wordKey] = true;
      });

      await _wordAudioPlayer.play(UrlSource(url));
      
      // Reset highlight after a delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _highlightedWords[wordKey] = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error playing word pronunciation: $e');
    }
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
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'صفحة $_currentPage',
                          style: TextStyles.font20PrimaryText.copyWith(
                            fontFamily: FontFamilyHelper.fontFamily1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'من 604',
                          style: TextStyles.font14PrimaryText.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Show verse details button
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      _showVerseDetails();
                    },
                    tooltip: 'تفاصيل الآيات',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: TextStyles.font16PrimaryText,
                                textAlign: TextAlign.center,
                              ),
                              verticalSpace(16),
                              ElevatedButton(
                                onPressed: () => _loadPage(_currentPage),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : _pageData == null
                          ? const Center(child: Text('لا توجد بيانات'))
                          : _buildPageContent(),
            ),

            // Page Navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < 604
                        ? () => _loadPage(_currentPage + 1)
                        : null,
                    color: AppColors.primaryColor,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_currentPage / 604',
                      style: TextStyles.font16PrimaryText.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => _loadPage(_currentPage - 1)
                        : null,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    // Display page as image (mushaf style)
    final imageUrl = 'https://cdn.islamic.network/quran/images/$_currentPage.png';
    
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primaryColor,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  verticalSpace(16),
                  Text(
                    'فشل تحميل الصفحة',
                    style: TextStyles.font16PrimaryText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  verticalSpace(16),
                  ElevatedButton(
                    onPressed: () => _loadPage(_currentPage),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showVerseDetails() {
    if (_pageData == null) return;
    
    final verses = _pageData!['verses'] as List<dynamic>? ?? [];
    
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
                    Text(
                      'آيات الصفحة $_currentPage',
                      style: TextStyles.font20PrimaryText.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Verses list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    final verse = verses[index] as Map<String, dynamic>;
                    return _buildVerseCard(verse);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard(Map<String, dynamic> verse) {
    final verseKey = verse['verse_key'] as String? ?? '';
    final text = verse['text_uthmani_simple'] as String? ?? '';
    final words = verse['words'] as List<dynamic>? ?? [];
    final parts = verseKey.split(':');
    final surahNumber = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final verseNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'آية $verseNumber',
                  style: TextStyles.font14PrimaryText.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(12),
          
          // Verse text - word by word or full text
          if (_isWordByWordMode && words.isNotEmpty)
            Wrap(
              textDirection: TextDirection.rtl,
              children: words.asMap().entries.map((entry) {
                final wordIndex = entry.key;
                final word = entry.value as Map<String, dynamic>;
                final wordText = word['text_uthmani'] as String? ?? '';
                final wordKey = '$surahNumber:$verseNumber:${wordIndex + 1}';
                final isHighlighted = _highlightedWords[wordKey] == true;

                return GestureDetector(
                  onTap: () => _playWordPronunciation(
                    surahNumber: surahNumber,
                    verseNumber: verseNumber,
                    wordPosition: wordIndex + 1,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? AppColors.primaryColor.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      wordText,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Amiri Quran',
                        color: isHighlighted
                            ? AppColors.primaryColor
                            : Colors.black87,
                        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              text,
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Amiri Quran',
                height: 2.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          
          verticalSpace(12),
          
          // Action buttons row - each button for one feature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Audio playback button
              _buildActionButton(
                icon: Icons.volume_up,
                label: 'تشغيل',
                onPressed: () async {
                  final audioService = QuranAudioService();
                  await audioService.playAyah(
                    surahNumber,
                    verseNumber,
                    reciter: _selectedReciter,
                  );
                },
              ),
              
              // Copy button
              _buildActionButton(
                icon: Icons.copy_outlined,
                label: 'نسخ',
                onPressed: () => _copyVerse(text, surahNumber, verseNumber),
              ),
              
              // Share button
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'مشاركة',
                onPressed: () => _shareVerse(text, surahNumber, verseNumber),
              ),
              
              // Tafsir button
              _buildActionButton(
                icon: Icons.menu_book_outlined,
                label: 'تفسير',
                onPressed: () => _showTafsirDialog(surahNumber, verseNumber),
              ),
              
              // Word-by-word toggle button
              _buildActionButton(
                icon: _isWordByWordMode ? Icons.text_fields : Icons.format_textdirection_r_to_l,
                label: _isWordByWordMode ? 'عادي' : 'كلمة',
                onPressed: () {
                  setState(() {
                    _isWordByWordMode = !_isWordByWordMode;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyles.font12PrimaryText.copyWith(
                color: AppColors.primaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyVerse(String text, int surahNumber, int verseNumber) async {
    await Clipboard.setData(
      ClipboardData(text: '$text [سورة $surahNumber - آية $verseNumber]'),
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

  void _shareVerse(String text, int surahNumber, int verseNumber) {
    Share.share(
      '$text\n\n[سورة $surahNumber - آية $verseNumber]',
      subject: 'آية من القرآن الكريم',
    );
  }

  void _showTafsirDialog(int surahNumber, int verseNumber) {
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
                            style: TextStyles.font20PrimaryText.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'سورة $surahNumber - آية $verseNumber',
                            style: TextStyles.font14PrimaryText.copyWith(
                              color: Colors.grey[600],
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
                  surahNumber: surahNumber,
                  ayahNumber: verseNumber,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
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
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: QuranTafsirService.availableTafsirs.entries.map((entry) {
                final isSelected = _selectedTafsir == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      entry.value['name'] ?? entry.key,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primaryColor,
                        fontFamily: 'Tajawal',
                        fontSize: 12,
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
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // Tafsir content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: TextStyles.font16PrimaryText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : _tafsirData[_selectedTafsir] == null
                      ? Center(
                          child: Text(
                            'لا يوجد تفسير متاح',
                            style: TextStyles.font16PrimaryText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          controller: widget.scrollController,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _tafsirData[_selectedTafsir] ?? '',
                            style: TextStyles.font16PrimaryText.copyWith(
                              height: 2.0,
                              fontFamily: 'Tajawal',
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
        ),
      ],
    );
  }
}

