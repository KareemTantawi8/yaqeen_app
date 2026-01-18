import 'package:flutter/material.dart';
import '../../../../core/common/widgets/custom_divider_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/utils/spacing.dart';
import 'widgets/quran_reading_tab.dart';
import 'widgets/quran_mushaf_tab.dart';
import 'widgets/quran_audio_tab.dart';
import 'widgets/quran_tafsir_tab.dart';
import 'widgets/quran_translations_tab.dart';
import 'widgets/quran_bookmarks_tab.dart';
import 'widgets/quran_memorization_tab.dart';
import 'widgets/quran_word_by_word_tab.dart';

/// Main Quran Screen with Modular Tab-Based Architecture
/// Primary Tab: Reading (Mushaf view, navigation, font & theme controls)
/// Secondary Tabs: Audio Recitation, Tafsir, Translations, Bookmarks & Notes,
///                 Memorization & Repeat Mode, Word-by-word / Grammar tools
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  static const String routeName = '/quran';

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 8 tabs: Reading, Mushaf, Audio, Tafsir, Translations, Bookmarks, Memorization, Word-by-word
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const DefaultAppBar(
                    title: 'القرآن الكريم',
                    icon: Icons.arrow_back,
                  ),
                  verticalSpace(8),
                  const CustomDividerWidget(),
                ],
              ),
            ),

            // Tab Bar - Scrollable for better mobile UX
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                automaticIndicatorColorAdjustment: false,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Colors.black54,
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyles.font16PrimaryText.copyWith(
                  fontFamily: FontFamilyHelper.fontFamily1,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: TextStyles.font14PrimaryText.copyWith(
                  fontFamily: FontFamilyHelper.fontFamily1,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.menu_book, size: 20),
                    text: 'القراءة',
                  ),
                  Tab(
                    icon: Icon(Icons.book, size: 20),
                    text: 'المصحف',
                  ),
                  Tab(
                    icon: Icon(Icons.headphones, size: 20),
                    text: 'الترتيل',
                  ),
                  Tab(
                    icon: Icon(Icons.menu_book_outlined, size: 20),
                    text: 'التفسير',
                  ),
                  Tab(
                    icon: Icon(Icons.translate_outlined, size: 20),
                    text: 'الترجمة',
                  ),
                  Tab(
                    icon: Icon(Icons.bookmark_border, size: 20),
                    text: 'المفضلة',
                  ),
                  Tab(
                    icon: Icon(Icons.psychology_outlined, size: 20),
                    text: 'الحفظ',
                  ),
                  Tab(
                    icon: Icon(Icons.format_textdirection_r_to_l, size: 20),
                    text: 'كلمة',
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  // Primary Tab: Reading
                  QuranReadingTab(),
                  
                  // Full Mushaf Tab
                  QuranMushafTab(),
                  
                  // Secondary Tabs
                  QuranAudioTab(),
                  QuranTafsirTab(),
                  QuranTranslationsTab(),
                  QuranBookmarksTab(),
                  QuranMemorizationTab(),
                  QuranWordByWordTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
