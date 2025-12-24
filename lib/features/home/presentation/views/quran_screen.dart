import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/refactors/qurans_list.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/recent_quran_read.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/reciters_list_tab.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
                    text: 'السورة',
                  ),
                  Tab(text: 'الترجمة'),
                  Tab(text: 'تشغيل'),
                ],
              ),
              verticalSpace(8),
              SizedBox(
                height: 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Surah List Tab with Pull-to-Refresh
                    RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _refreshSurahs,
                      color: AppColors.primaryColor,
                      child: const QuransList(),
                    ),
                    // Translation Tab (Coming Soon)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.translate,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          verticalSpace(16),
                          Text(
                            "الترجمة",
                            style: TextStyles.font20PrimaryText.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          verticalSpace(8),
                          Text(
                            "قريباً",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Tajawal',
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Audio Tab - Reciters List
                    const RecitersListTab(),
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
}
