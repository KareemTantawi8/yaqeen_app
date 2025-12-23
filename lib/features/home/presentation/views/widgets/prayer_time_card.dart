import 'package:flutter/material.dart';

import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/utils/spacing.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    super.key,
    required this.prayer,
    required this.image,
    required this.time,
  });
  final String prayer;
  final String image;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          prayer,
          style: TextStyles.font12WhiteText,
        ),
        verticalSpace(8),
        Image.asset(
          image,
        ),
        verticalSpace(8),
        Text(
          time,
          style: TextStyles.font12WhiteText,
        ),
      ],
    );
  }
}
