import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/styles/fonts/font_styles.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/Prayer/data/models/prayer_stats_model.dart';

class PrayerStatsWidget extends StatelessWidget {
  final PrayerStatsModel stats;

  const PrayerStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primaryColor,
                size: 24,
              ),
              horizontalSpace(8),
              Text(
                'إحصائيات الصلاة',
                style: TextStyles.font20PrimaryText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          verticalSpace(20),

          // Completion Percentage
          _buildCircularProgress(context),
          verticalSpace(24),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'السلسلة الحالية',
                  '${stats.currentStreak}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: _buildStatCard(
                  'أطول سلسلة',
                  '${stats.longestStreak}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
          verticalSpace(12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'صلوات مكتملة',
                  '${stats.completedPrayers}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: _buildStatCard(
                  'صلوات فائتة',
                  '${stats.missedPrayers}',
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),

          verticalSpace(20),
          const Divider(),
          verticalSpace(12),

          // Prayer-wise breakdown
          Text(
            'إحصائيات الصلوات (آخر 30 يوم)',
            style: TextStyles.font16PrimaryText.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpace(12),

          ...stats.prayerWiseStats.entries.map((entry) {
            final maxCount = 30; // 30 days
            final percentage = (entry.value / maxCount) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPrayerProgressBar(
                entry.key,
                entry.value,
                maxCount,
                percentage,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: stats.completionPercentage / 100,
              strokeWidth: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${stats.completionPercentage.toStringAsFixed(0)}%',
                style: TextStyles.font24PrimaryText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                'نسبة الإنجاز',
                style: TextStyles.font12PrimaryText.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          verticalSpace(8),
          Text(
            value,
            style: TextStyles.font24PrimaryText.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpace(4),
          Text(
            label,
            style: TextStyles.font12PrimaryText.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerProgressBar(
    String prayerName,
    int completed,
    int total,
    double percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              prayerName,
              style: TextStyles.font14PrimaryText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$completed/$total',
              style: TextStyles.font14PrimaryText.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        verticalSpace(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPrayerColor(prayerName),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPrayerColor(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return Colors.blue;
      case 'الظهر':
        return Colors.orange;
      case 'العصر':
        return Colors.amber;
      case 'المغرب':
        return Colors.deepOrange;
      case 'العشاء':
        return Colors.indigo;
      default:
        return AppColors.primaryColor;
    }
  }
}

