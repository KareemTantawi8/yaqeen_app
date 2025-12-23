import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class CustomCarousalWidget extends StatefulWidget {
  const CustomCarousalWidget({super.key});

  @override
  State<CustomCarousalWidget> createState() => _CustomCarousalWidgetState();
}

class _CustomCarousalWidgetState extends State<CustomCarousalWidget> {
  final List<String> imagePaths = [
    AppImages.boadCastImage,
    AppImages.boadCastImage,
    AppImages.boadCastImage,
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'بودكاستات مقترحة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2B7669) /* Primarycolor */,
                fontSize: 22,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w800,
                // height: 1,
              ),
            ),
          ),
          verticalSpace(8),
          CarouselSlider(
            options: CarouselOptions(
              height: 170,
              enlargeCenterPage: true,
              autoPlay: true,
              viewportFraction: 0.9,
              aspectRatio: 14 / 6,
              reverse: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: imagePaths.map((imagePath) {
              return Builder(
                builder: (context) {
                  return Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 170,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primaryColor.withOpacity(0.65),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              // Handle play action
                            },
                            child: Container(
                              height: 55,
                              width: 55,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 36,
                                color: Color.fromARGB(255, 23, 90, 79),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          ),
          verticalSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imagePaths.asMap().entries.map((entry) {
              final isSelected = _currentIndex == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isSelected ? 16 : 8,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
