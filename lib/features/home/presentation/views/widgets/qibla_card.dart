import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../../qibla/presentation/views/qibla_screen.dart';

class QiblaCard extends StatelessWidget {
  const QiblaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QiblaScreen(),
          ),
        );
      },
      child: Container(
        height: screenHeight * 0.2,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A5F54),
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -screenHeight * 0.03,
              right: -screenWidth * 0.08,
              child: Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -screenHeight * 0.02,
              left: -screenWidth * 0.06,
              child: Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                children: [
                  // Icon section
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.explore,
                          color: Colors.white,
                          size: screenWidth * 0.1,
                        ),
                        Positioned(
                          top: screenWidth * 0.02,
                          child: Icon(
                            Icons.navigation,
                            color: Colors.white.withOpacity(0.9),
                            size: screenWidth * 0.06,
                          ),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpace(screenWidth * 0.04),

                  // Text section
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.015),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              ),
                              child: Icon(
                                Icons.mosque,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                            ),
                            horizontalSpace(screenWidth * 0.02),
                            Text(
                              'اتجاه القبلة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(screenHeight * 0.01),
                        Text(
                          'اعثر على اتجاه الكعبة المشرفة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        verticalSpace(screenHeight * 0.015),
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
                              Text(
                                'افتح البوصلة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.035,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              horizontalSpace(screenWidth * 0.02),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: screenWidth * 0.04,
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
          ],
        ),
      ),
    );
  }
}

