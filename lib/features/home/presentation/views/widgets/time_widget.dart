
import 'package:flutter/material.dart';

import '../../../../../core/styles/fonts/font_styles.dart';

class TimeWIdget extends StatelessWidget {
  const TimeWIdget({
    super.key,
    required this.time,
  });
  final String time;

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      textAlign: TextAlign.center,
      style: TextStyles.font48WhiteText,
    );
  }
}
