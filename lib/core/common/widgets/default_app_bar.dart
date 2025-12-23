import 'package:flutter/material.dart';
import '../../extension/context_extension.dart';
import '../../styles/colors/app_color.dart';
import '../../styles/fonts/font_styles.dart';

class DefaultAppBar extends StatelessWidget {
  const DefaultAppBar({
    super.key,
    required this.title,
    this.icon,
  });
  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyles.font24WhiteText.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          height: 53,
          width: 53,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF9F4),
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Icon(
                icon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
