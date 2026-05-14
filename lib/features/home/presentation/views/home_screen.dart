import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/services/location_service.dart';
import 'package:yaqeen_app/core/services/prayer_calculator_service.dart';
import 'package:yaqeen_app/features/home/data/models/prayer_timings_model.dart';
import 'package:yaqeen_app/features/home/data/repo/prayer_times_service.dart';
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
import 'package:yaqeen_app/features/home/presentation/views/widgets/qibla_card.dart';
import 'package:yaqeen_app/features/events/presentation/views/events_screen.dart';

import 'widgets/prayer_times_loading_skeleton.dart';
import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';
import 'ahadis_screen.dart';
import 'adhan_full_screen.dart';
import 'mespha_screen.dart';
import 'widgets/hadith_daily_card.dart';
import '../../../qibla/presentation/views/qibla_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimingsModel? prayerTimings;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  Timer? _countdownTimer;
  String countdown = '00:00:00';
  Map<String, dynamic>? nextPrayer;
  double? currentLatitude;
  double? currentLongitude;
  String locationDescription = '';
  String? currentPrayerName;

  @override
  void initState() {
    super.initState();
    _initializeLocation();

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

  /// Initialize location and load prayer times.
  /// Loads immediately with cached/default location, then refreshes from GPS.
  Future<void> _initializeLocation() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      // Step 1: Use saved or default location immediately (instant — no GPS wait)
      final saved = await LocationService.getSavedLocation();
      final immediate = saved ??
          {
            'latitude': LocationService.defaultLatitude,
            'longitude': LocationService.defaultLongitude,
          };

      currentLatitude = immediate['latitude'];
      currentLongitude = immediate['longitude'];
      locationDescription = LocationService.getLocationDescription(
        currentLatitude!,
        currentLongitude!,
      );

      // Show prayer times right away
      await _loadPrayerTimes();

      // Step 2: Try GPS in background; silently refresh if location changed
      _refreshFromGps();
    } catch (e) {
      debugPrint('Failed to initialize location: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل البيانات';
      });
    }
  }

  Future<void> _refreshFromGps() async {
    try {
      final position = await LocationService.getCurrentLocation()
          .timeout(const Duration(seconds: 10));
      if (position == null || !mounted) return;

      final latDiff = (position.latitude - (currentLatitude ?? 0)).abs();
      final lngDiff = (position.longitude - (currentLongitude ?? 0)).abs();
      if (latDiff < 0.01 && lngDiff < 0.01) return; // no meaningful change

      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
      locationDescription = LocationService.getLocationDescription(
        position.latitude,
        position.longitude,
      );
      await _loadPrayerTimes(silent: true);
    } catch (_) {
      // GPS failed or timed out — prayer times already shown from cache
    }
  }

  Future<void> _loadPrayerTimes({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          isLoading = true;
          hasError = false;
          errorMessage = null;
        });
      }

      final response = await PrayerTimesService.getPrayerTimes(
        latitude: currentLatitude,
        longitude: currentLongitude,
      );

      // Calculate current prayer for highlighting
      final prayerTimes = PrayerCalculatorService.calculate(
        latitude: currentLatitude,
        longitude: currentLongitude,
        calculationMethodId: 4,
      );
      final currentPrayer = PrayerCalculatorService.getCurrentPrayerName(prayerTimes);

      final next = PrayerTimesService.getNextPrayer(
        response.timings,
        latitude: currentLatitude ?? PrayerTimesService.defaultLatitude,
        longitude: currentLongitude ?? PrayerTimesService.defaultLongitude,
      );

      setState(() {
        prayerTimings = response;
        nextPrayer = next;
        countdown = next['countdown'] as String;
        currentPrayerName = currentPrayer;
        isLoading = false;
      });

      // Start countdown timer
      _startCountdownTimer();
    } catch (e) {
      debugPrint('Failed to load prayer times: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل أوقات الصلاة';
      });
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prayerTimings != null && mounted) {
        final next = PrayerTimesService.getNextPrayer(
          prayerTimings!.timings,
          latitude: currentLatitude ?? PrayerTimesService.defaultLatitude,
          longitude: currentLongitude ?? PrayerTimesService.defaultLongitude,
        );
        setState(() {
          nextPrayer = next;
          countdown = next['countdown'];
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double notchRadius = 55;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const RectangleWidget(),

          // Loading state - modern shimmer skeleton
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Column(
                children: [
                  verticalSpace(8),
                  const PrayerTimesLoadingSkeleton(),
                  verticalSpace(30),
                  const PulsatingDots(),
                  verticalSpace(12),
                  Text(
                    'جاري تحميل أوقات الصلاة...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Error state - positioned at the top
          if (hasError && !isLoading)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    verticalSpace(40),
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    verticalSpace(16),
                    Text(
                      errorMessage ?? 'حدث خطأ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    verticalSpace(20),
                    ElevatedButton(
                      onPressed: _initializeLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content (when data is loaded)
          if (!isLoading && !hasError && prayerTimings != null)
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Column(
                children: [
                  HijriDateHeader(
                    hijrDateTitle: prayerTimings!.date.hijri.getFormattedDate(),
                  ),
                  verticalSpace(24),
                  PrayerNameWidget(
                    prayerName: nextPrayer?['name'] ?? 'الفجر',
                  ),
                  verticalSpace(12),
                  TimeWIdget(
                    time: nextPrayer?['time'] ?? '00:00',
                  ),
                  NextPrayerWidget(
                    nextPrayer: 'الصلاة التالية بعد $countdown',
                  ),
                  verticalSpace(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PrayerTimeCard(
                        prayer: 'العشاء',
                        image: AppImages.moonImage,
                        time: prayerTimings!.timings.isha,
                        isHighlighted: currentPrayerName == 'العشاء',
                      ),
                      PrayerTimeCard(
                        prayer: 'المغرب',
                        image: AppImages.cloudSunnyImage,
                        time: prayerTimings!.timings.maghrib,
                        isHighlighted: currentPrayerName == 'المغرب',
                      ),
                      PrayerTimeCard(
                        prayer: 'العصر',
                        image: AppImages.sunImage,
                        time: prayerTimings!.timings.asr,
                        isHighlighted: currentPrayerName == 'العصر',
                      ),
                      PrayerTimeCard(
                        prayer: 'الظهر',
                        image: AppImages.sunnyImage,
                        time: prayerTimings!.timings.dhuhr,
                        isHighlighted: currentPrayerName == 'الظهر',
                      ),
                      PrayerTimeCard(
                        prayer: 'الفجر',
                        image: AppImages.cloudefog,
                        time: prayerTimings!.timings.fajr,
                        isHighlighted: currentPrayerName == 'الفجر',
                      ),
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
                  child: SingleChildScrollView(
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
                        // 5 Feature circles in one row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            FeatureIconButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdhanFullScreen(),
                                  ),
                                );
                              },
                              image: AppImages.azanIcon,
                              text: 'أذان',
                            ),
                            horizontalSpace(8),
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
                            horizontalSpace(8),
                            FeatureIconButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QiblaScreen(),
                                  ),
                                );
                              },
                              image: AppImages.qeplaIcon,
                              text: 'قبلة',
                            ),
                            horizontalSpace(8),
                            FeatureIconButton(
                              onTap: () {
                                Navigator.pushNamed(context, MesphaScreen.routeName);
                              },
                              image: AppImages.mesphaIcon,
                              text: 'مسبحة',
                            ),
                            horizontalSpace(8),
                            FeatureIconButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EventsScreen(),
                                  ),
                                );
                              },
                              image: AppImages.eventIcon,
                              text: 'التقويم',
                            ),
                          ],
                        ),
                      ),
                      verticalSpace(30),
                      const RecentQuranRead(
                        key: ValueKey('recent_quran_read'),
                      ),
                      verticalSpace(16),
                      const QiblaCard(),
                      verticalSpace(16),
                      const HadithDailyCard(),
                      ],
                    ),
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
