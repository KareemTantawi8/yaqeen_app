import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/refactors/qurans_list.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/recent_quran_read.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/full_surah_player_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/quran_full_mushaf_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/surah_full_audio_screen.dart';

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
              
              // Quick access buttons for new features
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessButton(
                      context,
                      icon: Icons.menu_book,
                      label: 'المصحف الكامل',
                      onTap: () {
                        Navigator.pushNamed(context, QuranFullMushafScreen.routeName);
                      },
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: _buildQuickAccessButton(
                      context,
                      icon: Icons.headphones,
                      label: 'قراءة سورة كاملة',
                      onTap: () {
                        Navigator.pushNamed(context, SurahFullAudioScreen.routeName);
                      },
                    ),
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

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: 20,
            ),
            horizontalSpace(8),
            Flexible(
              child: Text(
                label,
                style: TextStyles.font14PrimaryText.copyWith(
                  color: AppColors.primaryColor,
                  fontFamily: FontFamilyHelper.fontFamily1,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
