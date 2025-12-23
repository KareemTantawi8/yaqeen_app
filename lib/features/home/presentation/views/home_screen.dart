import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/quran_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/Prayer_name_widget.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/clip_shadow_path.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/curved_top_clipper.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/feature_icon_button.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/hijr_date_widget.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/middle_notched_button.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/next_prayer_widget.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/prayer_time_card.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/recent_quran_read.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/rectangle_widget.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/time_widget.dart';

import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';
import 'ahadis_screen.dart';
import 'mespha_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    //! Uncomment the following lines to show the Ayah of the Day dialog after the first frame is rendered
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Use a different variable name to avoid conflicts with extensions named 'context'
    //   final dialogContext = context;
    //   showDialog(
    //     context: dialogContext,
    //     builder: (context) => const AyahOfTheDayDialog(),
    //   );
    // });
  }

  Widget build(BuildContext context) {
    @override
    const double notchRadius = 55;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const RectangleWidget(),

          // Top content (date + prayer info)
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
            child: Column(
              children: [
                const HijriDateHeader(hijrDateTitle: "9 محرم 1444 هـ"),
                verticalSpace(24),
                const PrayerNameWidget(prayerName: 'الفجر'),
                verticalSpace(12),
                const TimeWIdget(time: '03:25'),
                const NextPrayerWidget(
                    nextPrayer: 'الصلاة التالية بعد 03: 25 :15'),
                verticalSpace(16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PrayerTimeCard(
                        prayer: 'العشاء',
                        image: AppImages.moonImage,
                        time: '07:25'),
                    PrayerTimeCard(
                        prayer: 'المغرب',
                        image: AppImages.cloudSunnyImage,
                        time: '07:25'),
                    PrayerTimeCard(
                        prayer: 'العصر',
                        image: AppImages.sunImage,
                        time: '07:25'),
                    PrayerTimeCard(
                        prayer: 'الظهر',
                        image: AppImages.sunnyImage,
                        time: '07:25'),
                    PrayerTimeCard(
                        prayer: 'الفجر',
                        image: AppImages.cloudefog,
                        time: '07:25'),
                  ],
                ),
              ],
            ),
          ),

          // White container with curved top border
          Positioned(
            top: context.height * 0.42,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipShadowPath(
              clipper: CurvedTopClipper(notchRadius: notchRadius),
              shadow: const Shadow(
                blurRadius: 15,
                color: Colors.grey,
                offset: Offset(0, 10),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.boldText,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          'المميزات',
                          style: TextStyles.font24WhiteText.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      verticalSpace(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FeatureIconButton(
                            onTap: () {
                              log('printed');
                            },
                            image: AppImages.azanIcon,
                            text: 'أذان',
                          ),
                          FeatureIconButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AhadisScreen(),
                                ),
                              );
                            },
                            image: AppImages.socityIcon,
                            text: 'الاحاديث',
                          ),
                          FeatureIconButton(
                            onTap: () {},
                            image: AppImages.qeplaIcon,
                            text: 'قبلة',
                          ),
                          FeatureIconButton(
                            onTap: () {
                              context.pushName(MesphaScreen.routeName);
                            },
                            image: AppImages.mesphaIcon,
                            text: 'مسبحة',
                          ),
                          FeatureIconButton(
                            onTap: () {
                              context.pushName(QuranScreen.routeName);
                            },
                            image: AppImages.quranIcon,
                            text: 'قرأن',
                          ),
                        ],
                      ),
                      verticalSpace(30),
                      const RecentQuranRead(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Circle in notch
          const MiddleNotchButton(notchRadius: notchRadius),
        ],
      ),
    );
  }
}
