import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/utils/spacing.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    super.key,
    required this.prayer,
    required this.image,
    required this.time,
    this.isHighlighted = false,
  });

  final String prayer;
  final String image;
  final String time;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isHighlighted
          ? BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.8),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      padding: isHighlighted ? const EdgeInsets.all(8) : null,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Text(
                prayer,
                style: TextStyles.font12WhiteText,
              ),
              if (isHighlighted)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          verticalSpace(8),
          Image.asset(image),
          verticalSpace(8),
          Text(
            time,
            style: TextStyles.font12WhiteText,
          ),
        ],
      ),
    );
  }
}
