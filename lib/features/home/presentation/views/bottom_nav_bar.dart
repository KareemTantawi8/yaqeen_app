import 'package:flutter/material.dart';

import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../Azkar/presentation/views/azkar_screen.dart';
import '../../../Prayer/presntation/view/prayer_screen.dart';
import '../../../Settings/presentation/views/setting_screen.dart';
import 'quran_screen.dart';
import 'home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 2; // Start with Azkar

  final List<String> icons = [
    AppImages.azkarIcon,
    AppImages.prayerIcons,
    AppImages.homeIcon,
    AppImages.quranIcon,
    AppImages.settingIcons,
  ];

  final List<String> labels = [
    "الأذكار",
    "الصلاة",
    "الرئيسية",
    "القرآن",
    "المزيد",
  ];

  final List<Widget> screens = [
    const AzkarScreen(),
    const PrayerScreen(),
    const HomeScreen(),
    const QuranScreen(),
    const SettingScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          screens[currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.boldText,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Directionality(
                textDirection: TextDirection.ltr, // Force left to right
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(icons.length, (index) {
                    final bool isSelected = currentIndex == index;
                    return GestureDetector(
                      onTap: () => onItemTapped(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            // margin: const EdgeInsets.only(top: 8),
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                icons[index],
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[index],
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey[500],
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
