import 'dart:ui';

import 'package:flutter/material.dart';

class CurvedTopClipper extends CustomClipper<Path> {
  final double notchRadius;

  CurvedTopClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    const double cornerRadius = 28; // Slightly smaller for tighter corners
    final double curveDepth = 36;

    // Start from bottom-left
    path.moveTo(0, size.height);

    // Line to just before top-left corner
    path.lineTo(0, cornerRadius);

    // Soft top-left corner using custom control point
    path.quadraticBezierTo(
      0,
      0,
      cornerRadius,
      0,
    );
    path.quadraticBezierTo(
      0,
      0,
      cornerRadius,
      0,
    );

    // Line to left of notch
    double notchStartX = centerX - notchRadius;
    double notchEndX = centerX + notchRadius;
    double controlPointX1 = notchStartX + notchRadius * 0.4;
    double controlPointX2 = notchEndX - notchRadius * 0.4;

    path.lineTo(notchStartX, 0);

    // Left side of the notch
    path.cubicTo(
      controlPointX1,
      0,
      centerX - notchRadius * 0.6,
      curveDepth,
      centerX,
      curveDepth,
    );

    // Right side of the notch
    path.cubicTo(
      centerX + notchRadius * 0.6,
      curveDepth,
      controlPointX2,
      0,
      notchEndX,
      0,
    );

    // Line to just before top-right corner
    path.lineTo(size.width - cornerRadius, 0);

    // Soft top-right corner
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      cornerRadius,
    );

    // Down to bottom-right
    path.lineTo(size.width, size.height);

    // Back to bottom-left
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
