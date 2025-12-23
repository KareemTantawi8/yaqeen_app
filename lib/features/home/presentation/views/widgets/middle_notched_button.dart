import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../../core/extension/context_extension.dart';
import '../../../../../core/styles/images/app_image.dart';

class MiddleNotchButton extends StatelessWidget {
  const MiddleNotchButton({
    super.key,
    required this.notchRadius,
  });

  final double notchRadius;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: context.height * 0.42 - notchRadius / 2,
      child: Container(
        width: 54,
        height: 55,
        // padding: const EdgeInsets.all(15),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.90, -0.10),
            end: Alignment(0.20, 1.00),
            colors: [Color(0xFF50DCC3), Color(0xFF2B7669)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Center(
          child: Image.asset(
            AppImages.middleContainer,
            width: 45,
            height: 45,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
