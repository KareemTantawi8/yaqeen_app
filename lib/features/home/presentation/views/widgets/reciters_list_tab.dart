import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/reciter_model.dart';
import 'reciter_surahs_screen.dart';

class RecitersListTab extends StatelessWidget {
  const RecitersListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.all(screenWidth * 0.04),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.03,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.85),
                  const Color(0xFF1A5F54),
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: screenWidth * 0.05,
                  offset: Offset(0, screenHeight * 0.012),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.headset,
                    color: Colors.white,
                    size: screenWidth * 0.12,
                  ),
                ),
                verticalSpace(screenHeight * 0.02),
                Text(
                  'استمع للقرآن الكريم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.06,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                verticalSpace(screenHeight * 0.01),
                Text(
                  'اختر القارئ المفضل لديك',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: screenWidth * 0.035,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Popular Reciters Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.01,
                  height: screenHeight * 0.03,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                horizontalSpace(screenWidth * 0.03),
                Text(
                  'القراء المشهورون',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2221),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Reciters Grid
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 600 ? 3 : 2,
              childAspectRatio: screenWidth > 600 ? 0.9 : 0.85,
              crossAxisSpacing: screenWidth * 0.04,
              mainAxisSpacing: screenHeight * 0.02,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final reciter = RecitersList.popular[index];
                return _buildReciterCard(context, reciter, screenWidth, screenHeight);
              },
              childCount: RecitersList.popular.length,
            ),
          ),
        ),

        SliverToBoxAdapter(child: verticalSpace(screenHeight * 0.025)),
      ],
    );
  }

  Widget _buildReciterCard(BuildContext context, Reciter reciter, double screenWidth, double screenHeight) {
    final colors = [
      [const Color(0xFF2B7669), const Color(0xFF1A5F54)],
      [const Color(0xFF6B5B95), const Color(0xFF4A3F6B)],
      [const Color(0xFF00796B), const Color(0xFF004D40)],
      [const Color(0xFF5D4037), const Color(0xFF3E2723)],
      [const Color(0xFF1976D2), const Color(0xFF0D47A1)],
      [const Color(0xFF7B1FA2), const Color(0xFF4A148C)],
    ];
    
    final colorIndex = reciter.identifier.hashCode % colors.length;
    final gradient = colors[colorIndex];

    return Hero(
      tag: 'reciter_${reciter.identifier}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReciterSurahsScreen(reciter: reciter),
              ),
            );
          },
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradient[0], gradient[1]],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: screenWidth * 0.03,
                  offset: Offset(0, screenHeight * 0.008),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                // Decorative circles
                Positioned(
                  top: -screenWidth * 0.05,
                  right: -screenWidth * 0.05,
                  child: Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -screenWidth * 0.025,
                  left: -screenWidth * 0.025,
                  child: Container(
                    width: screenWidth * 0.125,
                    height: screenWidth * 0.125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: screenWidth * 0.08,
                        ),
                      ),
                      verticalSpace(screenHeight * 0.015),
                      
                      // Name
                      Flexible(
                        child: Text(
                          reciter.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.038,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      verticalSpace(screenHeight * 0.004),
                      
                      // English name
                      Flexible(
                        child: Text(
                          reciter.englishName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: screenWidth * 0.026,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      verticalSpace(screenHeight * 0.012),
                      
                      // Play button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: screenWidth * 0.04,
                            ),
                            horizontalSpace(screenWidth * 0.01),
                            Text(
                              'استماع',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

