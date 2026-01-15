import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/refactors/qurans_list.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/recent_quran_read.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/full_surah_player_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/quran_full_mushaf_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/surah_full_audio_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/quran_page_view_screen.dart';

import '../../../../core/common/widgets/custom_divider_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/utils/spacing.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  static const String routeName = '/quran';

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshSurahs() async {
    // Trigger rebuild of QuransList
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DefaultAppBar(
                title: 'القرآن الكريم',
                icon: Icons.arrow_back,
              ),
              verticalSpace(4),
              const CustomDividerWidget(),
              verticalSpace(8),
              const RecentQuranRead(
                key: ValueKey('recent_quran_read_quran'),
              ),
              verticalSpace(8),
              
              // Features section title
              Text(
                'المميزات',
                style: TextStyles.font20PrimaryText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamilyHelper.fontFamily1,
                ),
              ),
              verticalSpace(12),
              
              // Quick access buttons - each feature in separate button
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  // Full Mushaf feature
                  _buildFeatureButton(
                    context,
                    icon: Icons.menu_book,
                    label: 'المصحف الكامل',
                    onTap: () {
                      Navigator.pushNamed(context, QuranFullMushafScreen.routeName);
                    },
                  ),
                  
                  // Full Surah Audio feature
                  _buildFeatureButton(
                    context,
                    icon: Icons.headphones,
                    label: 'قراءة سورة كاملة',
                    onTap: () {
                      Navigator.pushNamed(context, SurahFullAudioScreen.routeName);
                    },
                  ),
                  
                  // Page by Page feature
                  _buildFeatureButton(
                    context,
                    icon: Icons.pages,
                    label: 'قراءة صفحة بصفحة',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuranPageViewScreen(initialPage: 1),
                        ),
                      );
                    },
                  ),
                  
                  // Read Surah feature (from tab)
                  _buildFeatureButton(
                    context,
                    icon: Icons.book,
                    label: 'قراءة السورة',
                    onTap: () {
                      _tabController.animateTo(0);
                    },
                  ),
                  
                  // Play Surah feature (from tab)
                  _buildFeatureButton(
                    context,
                    icon: Icons.play_circle_outline,
                    label: 'تشغيل السور',
                    onTap: () {
                      _tabController.animateTo(1);
                    },
                  ),
                ],
              ),
              verticalSpace(16),
              
              // Tab Bar
              TabBar(
                automaticIndicatorColorAdjustment: false,
                controller: _tabController,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Colors.black38,
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 5,
                labelStyle: TextStyles.font20PrimaryText.copyWith(
                  fontSize: 22,
                  color: AppColors.primaryColor,
                  fontFamily: FontFamilyHelper.fontFamily1,
                ),
                tabs: const [
                  Tab(
                    text: 'قراءة السورة',
                  ),
                  Tab(text: 'تشغيل السور'),
                ],
              ),
              verticalSpace(8),
              SizedBox(
                height: 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Surah List Tab - For Reading
                    RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _refreshSurahs,
                      color: AppColors.primaryColor,
                      child: const QuransList(),
                    ),
                    // Full Surah Player - For Listening
                    const FullSurahPlayerScreen(),
                  ],
                ),
              ),

              verticalSpace(16),
              // Only show surah list for now
              // _buildSurahList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: 28,
            ),
            verticalSpace(8),
            Text(
              label,
              style: TextStyles.font14PrimaryText.copyWith(
                color: AppColors.primaryColor,
                fontFamily: FontFamilyHelper.fontFamily1,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
