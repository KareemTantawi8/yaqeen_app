import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/services/location_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/home/data/models/prayer_timings_model.dart';
import 'package:yaqeen_app/features/home/data/repo/prayer_times_service.dart';
import 'package:yaqeen_app/features/Prayer/data/models/prayer_stats_model.dart';
import 'package:yaqeen_app/features/Prayer/data/repo/prayer_tracker_service.dart';
import 'package:yaqeen_app/features/Prayer/presentation/views/widgets/prayer_times_section.dart';
import 'package:yaqeen_app/features/Prayer/presentation/views/widgets/prayer_stats_widget.dart';
import 'package:yaqeen_app/features/Prayer/presentation/views/widgets/quick_actions_widget.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  PrayerTimingsModel? prayerTimings;
  PrayerStatsModel? prayerStats;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  Timer? _countdownTimer;
  String countdown = '00:00:00';
  Map<String, dynamic>? nextPrayer;
  double? currentLatitude;
  double? currentLongitude;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      // Get location
      final location = await LocationService.getLocationWithFallback();
      
      setState(() {
        currentLatitude = location['latitude'];
        currentLongitude = location['longitude'];
      });

      // Load prayer times and stats
      await Future.wait([
        _loadPrayerTimes(),
        _loadPrayerStats(),
      ]);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to initialize: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل البيانات';
      });
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final response = await PrayerTimesService.getPrayerTimes(
        latitude: currentLatitude,
        longitude: currentLongitude,
      );

      setState(() {
        prayerTimings = response;
        nextPrayer = PrayerTimesService.getNextPrayer(response.timings);
      });

      // Start countdown timer
      _startCountdownTimer();
    } catch (e) {
      debugPrint('Failed to load prayer times: $e');
      rethrow;
    }
  }

  Future<void> _loadPrayerStats() async {
    try {
      final stats = await PrayerTrackerService.getPrayerStats();
      setState(() {
        prayerStats = stats;
      });
    } catch (e) {
      debugPrint('Failed to load prayer stats: $e');
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prayerTimings != null && mounted) {
        final next = PrayerTimesService.getNextPrayer(prayerTimings!.timings);
        setState(() {
          nextPrayer = next;
          countdown = next['countdown'];
        });
      }
    });
  }

  Future<void> _refreshData() async {
    await _loadPrayerStats();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: isLoading
            ? _buildLoadingState()
            : hasError
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: _initializeData,
                    color: AppColors.primaryColor,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          _buildHeader(),
                          verticalSpace(20),

                          // Prayer Times Section
                          if (prayerTimings != null && nextPrayer != null)
                            PrayerTimesSection(
                              prayerTimings: prayerTimings!,
                              nextPrayer: nextPrayer!,
                              countdown: countdown,
                              onRefresh: _refreshData,
                            ),
                          verticalSpace(20),

                          // Quick Actions
                          const QuickActionsWidget(),
                          verticalSpace(20),

                          // Prayer Statistics
                          if (prayerStats != null)
                            PrayerStatsWidget(stats: prayerStats!),

                          verticalSpace(100), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.mosque,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أوقات الصلاة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              Text(
                'تتبع صلواتك اليومية',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
          verticalSpace(16),
          Text(
            'جاري تحميل أوقات الصلاة...',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            verticalSpace(16),
            Text(
              errorMessage ?? 'حدث خطأ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace(24),
            ElevatedButton(
              onPressed: _initializeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
