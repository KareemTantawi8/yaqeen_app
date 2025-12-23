import 'package:flutter/material.dart';

import '../../../../../core/utils/spacing.dart';

// ignore: must_be_immutable
class FeatureIconButton extends StatelessWidget {
  FeatureIconButton({
    super.key,
    required this.text,
    required this.image,
    this.onTap,
  });
  void Function()? onTap;
  final String text;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 53,
            width: 53,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF9F4),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              image,
            ),
          ),
        ),
        verticalSpace(5),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF2B7669) /* Primarycolor */,
            fontSize: 14,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w500,
            height: 1.71,
            letterSpacing: 0.15,
          ),
        )
      ],
    );
  }
}
