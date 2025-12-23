import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';

// ignore: must_be_immutable
class CustomServiceWidget extends StatelessWidget {
  CustomServiceWidget({
    super.key,
    required this.image,
    required this.onTap,
    required this.title,
  });
  final String image;
  void Function()? onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 65,
            width: 65,
            padding: const EdgeInsets.all(12.70),
            decoration: ShapeDecoration(
              color: const Color(0xFFEAF9F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(800),
              ),
            ),
            child: Center(
              child: Image.asset(
                image,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        verticalSpace(8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF2B7669) /* Primarycolor */,
            fontSize: 11.67,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            height: 1.43,
            letterSpacing: 0.08,
          ),
        )
      ],
    );
  }
}
