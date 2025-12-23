import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class RecentQuranRead extends StatelessWidget {
  const RecentQuranRead({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.26, // ~200 on medium screen
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: screenHeight * 0.23, // ~180
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment(1.05, 0.02),
                end: Alignment(0.00, 0.98),
                colors: [
                  Color(0xFF206B5E),
                  Color(0xFF329A88),
                ],
              ),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(AppImages.triangleImage),
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06, // ~24
                vertical: screenHeight * 0.03, // ~24
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.80,
                    child: Text(
                      'القراءة مؤخرا',
                      style: TextStyle(
                        color: const Color(0xFFEAF9F4),
                        fontSize: screenWidth * 0.035, // ~14
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                  verticalSpace(screenHeight * 0.007),
                  Text(
                    'الفاتحة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.08, // ~32
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Opacity(
                    opacity: 0.80,
                    child: Text(
                      'آية رقم.25',
                      style: TextStyle(
                        color: const Color(0xFFEAF9F4),
                        fontSize: screenWidth * 0.035, // ~14
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                  verticalSpace(screenHeight * 0.02),
                  SizedBox(
                    height: screenHeight * 0.045,
                    width: screenWidth * 0.3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Icon(
                                Icons.arrow_forward,
                                color: AppColors.primaryColor,
                                size: screenWidth * 0.05, // ~20
                              ),
                            ),
                            Text(
                              'استمرار',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF2B7669),
                                fontSize: screenWidth * 0.04, // ~16
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Moshaf image overflow
          Positioned(
            left: 8,
            bottom: screenHeight * 0.014, // ~30
            child: Image.asset(
              AppImages.mosafImage,
              height: screenHeight * 0.28, // ~185
              width: screenWidth * 0.45, // ~170 on 400 width screen
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
