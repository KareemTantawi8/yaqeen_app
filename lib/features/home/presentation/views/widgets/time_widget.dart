import 'package:flutter/material.dart';

import '../../../../../core/services/prayer_calculator_service.dart';
import '../../../../../core/styles/fonts/font_styles.dart';

class TimeWIdget extends StatelessWidget {
  const TimeWIdget({super.key, required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    final formatted = PrayerCalculatorService.formatDisplayTime(time);
    final spaceIndex = formatted.lastIndexOf(' ');
    final clockPart = spaceIndex > 0
        ? formatted.substring(0, spaceIndex)
        : formatted;
    final periodPart = spaceIndex > 0
        ? formatted.substring(spaceIndex + 1)
        : '';

    final clockStyle = TextStyles.font48WhiteText.copyWith(fontSize: 34);
    final periodStyle = TextStyles.font14WhiteText.copyWith(fontSize: 16);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: TextDirection.rtl,
      children: [
        Text(clockPart, textAlign: TextAlign.center, style: clockStyle),
        if (periodPart.isNotEmpty) ...[
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(periodPart, style: periodStyle),
          ),
        ],
      ],
    );
  }
}
