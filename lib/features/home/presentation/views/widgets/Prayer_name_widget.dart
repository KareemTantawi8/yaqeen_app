
import 'package:flutter/material.dart';

import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/styles/images/app_image.dart';

class PrayerNameWidget extends StatelessWidget {
  const PrayerNameWidget({
    super.key,
    required this.prayerName,
  });
  final String prayerName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prayerName,
            textAlign: TextAlign.center,
            style: TextStyles.font24WhiteText,
          ),
          Image.asset(AppImages.cloudeImage),
        ],
      ),
    );
  }
}
