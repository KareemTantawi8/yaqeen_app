import 'package:flutter/material.dart';
import '../../../../core/common/widgets/custom_divider_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/utils/spacing.dart';
import 'quran_read_screen.dart';
import 'quran_audio_screen.dart';
import 'quran_tafsir_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});
  static const String routeName = '/quran';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    title: 'القرآن الكريم',
                    icon: Icons.arrow_back,
                  ),
                  verticalSpace(8),
                  const CustomDividerWidget(),
                ],
              ),
            ),

            // 3 Feature Cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    verticalSpace(16),
                    // القراءة Card
                    _buildQuranFeatureCard(
                      context,
                      title: 'القراءة',
                      description: 'اقرأ القرآن الكريم كاملا',
                      icon: Icons.menu_book,
                      gradientStart: const Color(0xFF2B7669),
                      gradientEnd: const Color(0xFF1A5C51),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuranReadScreen(),
                          ),
                        );
                      },
                    ),
                    verticalSpace(16),
                    // الاستماع Card
                    _buildQuranFeatureCard(
                      context,
                      title: 'الاستماع',
                      description: 'استمع لتلاوة القرآن الكريم',
                      icon: Icons.headphones,
                      gradientStart: const Color(0xFF1976D2),
                      gradientEnd: const Color(0xFF0D47A1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuranAudioScreen(),
                          ),
                        );
                      },
                    ),
                    verticalSpace(16),
                    // التفسير Card
                    _buildQuranFeatureCard(
                      context,
                      title: 'التفسير',
                      description: 'اطلع على تفسير آيات القرآن',
                      icon: Icons.menu_book_outlined,
                      gradientStart: const Color(0xFF00796B),
                      gradientEnd: const Color(0xFF004D40),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuranTafsirScreen(),
                          ),
                        );
                      },
                    ),
                    verticalSpace(40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color gradientStart,
    required Color gradientEnd,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                // Right side - Arrow icon
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ),
                const Spacer(),

                // Center - Text content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      verticalSpace(4),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),

                // Left side - Icon in circle
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
