import 'package:flutter/material.dart';

import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../Azkar/presentation/views/azkar_screen.dart';
import '../../../Settings/presentation/views/setting_screen.dart';
import '../../../mosque/presentation/views/mosque_map_screen.dart';
import 'quran_audio_screen.dart';
import 'home_screen.dart';

class BottomNavBar extends StatefulWidget {
  static const String routeName = '/main';

  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 2; // Start with Home

  final List<IconData?> icons = [
    null, // Will use asset for azkar
    Icons.headphones,
    null, // Will use asset for home
    Icons.mosque,
    null, // Will use asset for settings
  ];

  final List<String> assetIcons = [
    AppImages.azkarIcon,
    '', // Not used for headphones
    AppImages.homeIcon,
    '', // Not used for mosque
    AppImages.settingIcons,
  ];

  final List<String> labels = [
    "الأذكار",
    "الاستماع",
    "الرئيسية",
    "مساجد",
    "المزيد",
  ];

  final List<Widget> screens = [
    const AzkarScreen(),
    const QuranAudioScreen(),
    const HomeScreen(),
    const MosqueMapScreen(),
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
                    final isAssetIcon = icons[index] == null;

                    return GestureDetector(
                      onTap: () => onItemTapped(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isAssetIcon
                                  ? Image.asset(
                                      assetIcons[index],
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      width: 22,
                                      height: 22,
                                    )
                                  : Icon(
                                      icons[index],
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      size: 22,
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
