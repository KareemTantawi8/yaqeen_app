import 'package:flutter/material.dart';

import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../Azkar/presentation/views/azkar_screen.dart';
import '../../../Settings/presentation/views/setting_screen.dart';
import '../../../mosque/presentation/views/mosque_list_screen.dart';
import 'quran_hub_screen.dart';
import 'home_screen.dart';

class BottomNavBar extends StatefulWidget {
  static const String routeName = '/main';

  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 2;

  final List<IconData> icons = [
    Icons.self_improvement_rounded,
    Icons.auto_stories_rounded,
    Icons.home_rounded,
    Icons.mosque_rounded,
    Icons.settings_rounded,
  ];

  final List<String> labels = [
    "الأذكار",
    "القرآن",
    "الرئيسية",
    "مساجد",
    "المزيد",
  ];

  final List<Widget> screens = [
    const AzkarScreen(),
    const QuranHubScreen(),
    const HomeScreen(),
    const MosqueListScreen(),
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
      backgroundColor: context.scaffoldBg,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.navBarBg,
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
                textDirection: TextDirection.ltr,
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
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                icons[index],
                                color: isSelected
                                    ? Colors.white
                                    : context.navIconUnselected,
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
                                  : context.greyText500,
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
