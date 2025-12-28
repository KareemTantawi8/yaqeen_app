import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/styles/fonts/font_styles.dart';
import 'package:yaqeen_app/core/styles/images/app_image.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/home/data/models/prayer_timings_model.dart';
import 'package:yaqeen_app/features/Prayer/data/repo/prayer_tracker_service.dart';

class PrayerTimesSection extends StatefulWidget {
  final PrayerTimingsModel prayerTimings;
  final Map<String, dynamic> nextPrayer;
  final String countdown;
  final VoidCallback onRefresh;

  const PrayerTimesSection({
    super.key,
    required this.prayerTimings,
    required this.nextPrayer,
    required this.countdown,
    required this.onRefresh,
  });

  @override
  State<PrayerTimesSection> createState() => _PrayerTimesSectionState();
}

class _PrayerTimesSectionState extends State<PrayerTimesSection> {
  Map<String, bool> prayerCompletions = {};

  @override
  void initState() {
    super.initState();
    _loadPrayerCompletions();
  }

  Future<void> _loadPrayerCompletions() async {
    final today = DateTime.now();
    final completions =
        await PrayerTrackerService.getPrayerCompletionsForDate(today);

    setState(() {
      prayerCompletions = {
        for (var completion in completions)
          completion.prayerName: completion.isCompleted
      };
    });
  }

  Future<void> _togglePrayer(String prayerName) async {
    await PrayerTrackerService.togglePrayerCompletion(
        DateTime.now(), prayerName);
    await _loadPrayerCompletions();
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hijri Date
          Text(
            widget.prayerTimings.date.hijri.getFormattedDate(),
            style: TextStyles.font16WhiteText.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          verticalSpace(16),

          // Next Prayer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'الصلاة القادمة',
                  style: TextStyles.font14WhiteText.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                verticalSpace(8),
                Text(
                  widget.nextPrayer['name'] ?? 'الفجر',
                  style: TextStyles.font32WhiteText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                verticalSpace(4),
                Text(
                  widget.nextPrayer['time'] ?? '00:00',
                  style: TextStyles.font24WhiteText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                verticalSpace(12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      horizontalSpace(8),
                      Text(
                        'بعد ${widget.countdown}',
                        style: TextStyles.font14WhiteText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          verticalSpace(20),

          // All Prayer Times
          _buildPrayerTimeRow(
            'الفجر',
            widget.prayerTimings.timings.fajr,
            AppImages.cloudefog,
            prayerCompletions['الفجر'] ?? false,
          ),
          verticalSpace(12),
          _buildPrayerTimeRow(
            'الظهر',
            widget.prayerTimings.timings.dhuhr,
            AppImages.sunnyImage,
            prayerCompletions['الظهر'] ?? false,
          ),
          verticalSpace(12),
          _buildPrayerTimeRow(
            'العصر',
            widget.prayerTimings.timings.asr,
            AppImages.sunImage,
            prayerCompletions['العصر'] ?? false,
          ),
          verticalSpace(12),
          _buildPrayerTimeRow(
            'المغرب',
            widget.prayerTimings.timings.maghrib,
            AppImages.cloudSunnyImage,
            prayerCompletions['المغرب'] ?? false,
          ),
          verticalSpace(12),
          _buildPrayerTimeRow(
            'العشاء',
            widget.prayerTimings.timings.isha,
            AppImages.moonImage,
            prayerCompletions['العشاء'] ?? false,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(
    String prayerName,
    String time,
    String icon,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.greenAccent.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _togglePrayer(prayerName),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.greenAccent
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ),
          horizontalSpace(12),

          // Prayer Icon
          Image.asset(
            icon,
            width: 32,
            height: 32,
            color: Colors.white.withOpacity(0.9),
          ),
          horizontalSpace(12),

          // Prayer Name
          Expanded(
            child: Text(
              prayerName,
              style: TextStyles.font18WhiteText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration:
                    isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          // Prayer Time
          Text(
            time,
            style: TextStyles.font18WhiteText.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

