import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/styles/fonts/font_styles.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';

class NightPortionsCard extends StatelessWidget {
  final SunnahTimes sunnahTimes;

  const NightPortionsCard({
    super.key,
    required this.sunnahTimes,
  });

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
            AppColors.primaryColor.withOpacity(0.85),
            AppColors.primaryColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with moon icon
          Row(
            children: [
              Icon(
                Icons.nights_stay,
                color: Colors.white,
                size: 24,
              ),
              horizontalSpace(12),
              Text(
                'أوقات الليل',
                style: TextStyles.font18WhiteText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          verticalSpace(20),

          // Night portions rows
          _buildNightPortionRow(
            'منتصف الليل',
            _formatTime(sunnahTimes.middleOfTheNight),
            Icons.brightness_3,
          ),
          verticalSpace(16),
          _buildNightPortionRow(
            'الثلث الأخير',
            _formatTime(sunnahTimes.lastThirdOfTheNight),
            Icons.dark_mode,
          ),
        ],
      ),
    );
  }

  Widget _buildNightPortionRow(String label, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
          horizontalSpace(12),
          Expanded(
            child: Text(
              label,
              style: TextStyles.font16WhiteText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyles.font16WhiteText.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
