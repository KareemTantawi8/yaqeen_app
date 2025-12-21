import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/style/app_colors.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background color
        Container(
          color: AppColors.primary,
        ),
        // Geometric pattern overlay (simplified)
        CustomPaint(
          painter: GeometricPatternPainter(),
          child: Container(),
        ),
        // Mosque silhouettes at the bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            painter: MosqueSilhouettePainter(),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Draw simplified geometric pattern (star-like shapes)
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw multiple star patterns
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final radius = 80.0 + (i * 20);
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      _drawStar(canvas, paint, Offset(x, y), 15);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    final points = 8;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final r = i.isEven ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MosqueSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw simplified mosque silhouettes (minarets and domes)
    final minaretWidth = size.width * 0.08;
    final minaretHeight = size.height * 0.6;
    final domeRadius = minaretWidth * 0.8;

    // Left minaret
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.15,
        size.height - minaretHeight,
        minaretWidth,
        minaretHeight,
      ),
      paint,
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.15 + minaretWidth / 2,
        size.height - minaretHeight,
      ),
      domeRadius,
      paint,
    );

    // Center minaret (larger)
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height - minaretHeight * 1.2,
        minaretWidth * 1.2,
        minaretHeight * 1.2,
      ),
      paint,
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.45 + (minaretWidth * 1.2) / 2,
        size.height - minaretHeight * 1.2,
      ),
      domeRadius * 1.2,
      paint,
    );

    // Right minaret
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.75,
        size.height - minaretHeight,
        minaretWidth,
        minaretHeight,
      ),
      paint,
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.75 + minaretWidth / 2,
        size.height - minaretHeight,
      ),
      domeRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

