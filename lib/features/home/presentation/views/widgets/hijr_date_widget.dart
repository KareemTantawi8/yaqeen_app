import 'package:flutter/material.dart';

import '../../../../../core/styles/fonts/font_styles.dart';

class HijriDateHeader extends StatelessWidget {
  const HijriDateHeader({
    super.key,
    required this.hijrDateTitle,
  });
  final String hijrDateTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hijrDateTitle,
          textAlign: TextAlign.center,
          style: TextStyles.font14WhiteText,
        ),
        const Icon(
          Icons.notifications_none,
          color: Colors.white,
        ),
      ],
    );
  }
}
