import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/styles/fonts/font_family_helper.dart';
import 'package:yaqeen_app/core/styles/fonts/font_styles.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/home/presentation/views/refactors/qurans_list.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/recent_quran_read.dart';
import 'package:yaqeen_app/features/home/presentation/views/quran_page_view_screen.dart';

/// Primary Tab: Quran Reading Only
/// Features: Mushaf view, Page/Surah navigation, Font & theme controls
class QuranReadingTab extends StatefulWidget {
  const QuranReadingTab({super.key});

  @override
  State<QuranReadingTab> createState() => _QuranReadingTabState();
}

class _QuranReadingTabState extends State<QuranReadingTab> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshSurahs() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshSurahs,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent reading
            const RecentQuranRead(
              key: ValueKey('recent_quran_read_tab'),
            ),
            verticalSpace(16),

            // Quick access cards
            _buildQuickAccessSection(),

            verticalSpace(16),

            // Surahs list for reading
            Text(
              'السور',
              style: TextStyles.font20PrimaryText.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: FontFamilyHelper.fontFamily1,
              ),
            ),
            verticalSpace(12),
            SizedBox(
              height: 400,
              child: const QuransList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوصول السريع',
          style: TextStyles.font18PrimaryText.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: FontFamilyHelper.fontFamily1,
          ),
        ),
        verticalSpace(12),
        _buildQuickAccessCard(
          icon: Icons.pages,
          label: 'صفحة بصفحة',
          description: 'قراءة حسب الصفحات',
          color: const Color(0xFF6B5B95),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const QuranPageViewScreen(initialPage: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyles.font16WhiteText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalSpace(4),
                  Text(
                    description,
                    style: TextStyles.font12WhiteText.copyWith(
                      color: Colors.white.withOpacity(0.9),
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
}

