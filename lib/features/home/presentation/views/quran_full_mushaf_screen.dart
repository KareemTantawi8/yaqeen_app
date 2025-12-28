import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../data/models/quran_full_model.dart';
import '../../data/repo/quran_full_service.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/common/widgets/default_app_bar.dart';
import '../../../../../core/utils/spacing.dart';

class QuranFullMushafScreen extends StatefulWidget {
  const QuranFullMushafScreen({super.key});
  static const String routeName = '/quran-full-mushaf';

  @override
  State<QuranFullMushafScreen> createState() => _QuranFullMushafScreenState();
}

class _QuranFullMushafScreenState extends State<QuranFullMushafScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  QuranFullTextModel? _quranData;
  QuranFullImageModel? _quranImages;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedMushaf = 'quran-uthmani';
  
  final List<Map<String, String>> _mushafTypes = [
    {'value': 'quran-uthmani', 'label': 'الرسم العثماني'},
    {'value': 'quran-simple', 'label': 'رسم مبسط'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadQuranData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _loadQuranData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_tabController.index == 0) {
        // Load text version
        final data = await QuranFullService.getFullQuranText(
          edition: _selectedMushaf,
        );
        setState(() {
          _quranData = data;
          _isLoading = false;
        });
      } else {
        // Load image version
        final images = await QuranFullService.getFullQuranImages();
        setState(() {
          _quranImages = images;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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
                    title: 'المصحف الكامل',
                    icon: Icons.arrow_back,
                  ),
                  verticalSpace(12),
                  
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) {
                        _loadQuranData();
                      },
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.primaryColor,
                      indicator: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyles.font18PrimaryText.copyWith(
                        fontFamily: FontFamilyHelper.fontFamily1,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: TextStyles.font16PrimaryText.copyWith(
                        fontFamily: FontFamilyHelper.fontFamily1,
                      ),
                      tabs: const [
                        Tab(text: 'قراءة النص'),
                        Tab(text: 'صفحات المصحف'),
                      ],
                    ),
                  ),
                  
                  // Mushaf type selector (only for text tab)
                  if (_tabController.index == 0)
                    FadeIn(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _mushafTypes.map((type) {
                            final isSelected = _selectedMushaf == type['value'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMushaf = type['value']!;
                                });
                                _loadQuranData();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  type['label']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.grey[600],
                                    fontFamily: FontFamilyHelper.fontFamily1,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTextView(),
                  _buildImageView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextView() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_quranData == null) {
      return const Center(
        child: Text('لا توجد بيانات'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuranData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quranData!.surahs.length,
        itemBuilder: (context, index) {
          final surah = _quranData!.surahs[index];
          return FadeInUp(
            delay: Duration(milliseconds: 50 * index),
            duration: const Duration(milliseconds: 400),
            child: _buildSurahCard(surah),
          );
        },
      ),
    );
  }

  Widget _buildImageView() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_quranImages == null) {
      return const Center(
        child: Text('لا توجد صفحات'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuranData,
      color: AppColors.primaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _quranImages!.pages.length,
        itemBuilder: (context, index) {
          final page = _quranImages!.pages[index];
          return FadeInUp(
            delay: Duration(milliseconds: 30 * index),
            duration: const Duration(milliseconds: 400),
            child: _buildPageCard(page),
          );
        },
      ),
    );
  }

  Widget _buildSurahCard(SurahTextModel surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          _showSurahDetails(surah);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Surah number badge
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${surah.surahId}',
                        style: TextStyles.font18PrimaryText.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace(12),
                  
                  // Surah name and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.name,
                          style: TextStyles.font20PrimaryText.copyWith(
                            fontFamily: FontFamilyHelper.fontFamily1,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (surah.nameEnglish != null) ...[
                          verticalSpace(4),
                          Text(
                            surah.nameEnglish!,
                            style: TextStyles.font14PrimaryText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              
              if (surah.numberOfAyahs != null || surah.revelationType != null) ...[
                verticalSpace(12),
                Divider(color: Colors.grey[200]),
                verticalSpace(8),
                Row(
                  children: [
                    if (surah.numberOfAyahs != null) ...[
                      Icon(Icons.list_alt, size: 16, color: Colors.grey[600]),
                      horizontalSpace(6),
                      Text(
                        '${surah.numberOfAyahs} آية',
                        style: TextStyles.font14PrimaryText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (surah.revelationType != null) horizontalSpace(16),
                    ],
                    if (surah.revelationType != null) ...[
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      horizontalSpace(6),
                      Text(
                        surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                        style: TextStyles.font14PrimaryText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(QuranPageModel page) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showPageFullScreen(page);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  page.imageUrl,
                  fit: BoxFit.cover,
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
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  horizontalSpace(6),
                  Text(
                    'صفحة ${page.page}',
                    style: TextStyles.font16PrimaryText.copyWith(
                      color: AppColors.primaryColor,
                      fontFamily: FontFamilyHelper.fontFamily1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
          verticalSpace(16),
          Text(
            'جاري تحميل المصحف الكريم...',
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
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
              onPressed: _loadQuranData,
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

  void _showSurahDetails(SurahTextModel surah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
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
                child: Column(
                  children: [
                    Text(
                      surah.name,
                      style: TextStyles.font24WhiteText.copyWith(
                        color: AppColors.primaryColor,
                        fontFamily: FontFamilyHelper.fontFamily1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (surah.nameEnglish != null) ...[
                      verticalSpace(4),
                      Text(
                        surah.nameEnglish!,
                        style: TextStyles.font14PrimaryText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Ayahs list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: surah.ayahs.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[200],
                    height: 24,
                  ),
                  itemBuilder: (context, index) {
                    final ayah = surah.ayahs[index];
                    return _buildAyahItem(ayah, index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAyahItem(AyahTextModel ayah, int displayNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ayah number
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$displayNumber',
              style: TextStyles.font14PrimaryText.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        horizontalSpace(12),
        
        // Ayah text
        Expanded(
          child: Text(
            ayah.text,
            style: TextStyles.font18PrimaryText.copyWith(
              fontFamily: 'Amiri Quran',
              height: 1.8,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  void _showPageFullScreen(QuranPageModel page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'صفحة ${page.page}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                page.imageUrl,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

