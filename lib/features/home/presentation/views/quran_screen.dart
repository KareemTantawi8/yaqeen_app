import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/refactors/qurans_list.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/recent_quran_read.dart';

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
              const RecentQuranRead(),
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
                  children: const [
                    // _buildSurahList(),
                    QuransList(),
                    Center(
                        child: Text("الترجمة", style: TextStyle(fontSize: 18))),
                    Center(
                        child: Text("تشغيل", style: TextStyle(fontSize: 18))),
                  ],
                ),
              ),

              verticalSpace(8),
              // Only show surah list for now
              // _buildSurahList(),
            ],
          ),
        ),
      ),
    );
  }
}
