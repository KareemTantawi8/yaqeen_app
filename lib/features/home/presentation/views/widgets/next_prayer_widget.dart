
import 'package:flutter/material.dart';

import '../../../../../core/styles/fonts/font_styles.dart';

class NextPrayerWidget extends StatelessWidget {
  const NextPrayerWidget({
    super.key,
    required this.nextPrayer,
  });
  final String nextPrayer;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.80,
      child: Text(
        nextPrayer,
        textAlign: TextAlign.center,
        style: TextStyles.font14WhiteText,
      ),
    );
  }
}
