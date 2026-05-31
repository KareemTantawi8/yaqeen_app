
import 'package:flutter/material.dart';

import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class PrayerNameWidget extends StatelessWidget {
  const PrayerNameWidget({
    super.key,
    required this.prayerName,
    this.image,
  });
  final String prayerName;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
        prayerName,
        textAlign: TextAlign.center,
        style: TextStyles.font24WhiteText,
      ),

        Image.asset(
          image ?? AppImages.cloudeImage,
          width: 48,
          height: 48,
        ),
        // verticalSpace(8),8

      ],
    );
  }
}
