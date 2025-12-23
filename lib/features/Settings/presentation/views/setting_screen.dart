import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yaqeen_app/features/Settings/presentation/views/widgets/custom_cursoal_widget.dart';
import 'package:yaqeen_app/features/Settings/presentation/views/widgets/custom_service_widget.dart';
import 'package:yaqeen_app/features/Settings/presentation/views/widgets/setting_app_bar_widget.dart';
import 'package:yaqeen_app/features/Settings/presentation/views/widgets/setting_option_tile.dart';

import '../../../../core/common/widgets/custom_divider_widget.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';
import 'allah_names_screen.dart';
import 'books_screen.dart';
import 'radio_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // bool isToggle = true;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SettingAppBarWidget(),
              verticalSpace(3),
              const CustomDividerWidget(),
              verticalSpace(3),
              // Carousel slider
              const CustomCarousalWidget(),
              verticalSpace(16),
              const CustomDividerWidget(),
              verticalSpace(5),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'خدمات اخري',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomServiceWidget(
                    image: AppImages.bestIcon,
                    title: 'اسماء الله',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllahNamesScreen(),
                        ),
                      );
                    },
                  ),
                  CustomServiceWidget(
                    image: AppImages.radioIcon,
                    title: 'الراديو',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RadioScreen(),
                        ),
                      );
                    },
                  ),
                  CustomServiceWidget(
                    image: AppImages.bookIcon,
                    title: 'كتب',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BooksScreen(),
                        ),
                      );
                    },
                  ),
                  CustomServiceWidget(
                    image: AppImages.yaqeenImage,
                    title: 'أسأل يقين ؟',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => YaqeenScreen(),
                      //   ),YaqeenScreen
                      // );
                    },
                  ),
                ],
              ),
              verticalSpace(24),
              SettingToggleTile(
                title: 'الوضع المظلم',
                onTap: () {},
                icon: Icons.toggle_on,
              ),
              verticalSpace(12),
              SettingToggleTile(
                title: 'تقييم التطبيق',
                onTap: () {},
                icon: Icons.star,
                iconSize: 25,
              ),
              verticalSpace(12),

              SettingToggleTile(
                title: 'مشاركة التطبيق',
                onTap: () {
                  Share.share(
                    'جرب تطبيقنا الرائع من هنا:\nhttps://play.google.com/store/apps/details?id=com.example.app',
                    subject: 'مشاركة التطبيق',
                  );
                },
                icon: Icons.share,
                iconSize: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
