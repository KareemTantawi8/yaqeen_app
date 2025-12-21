import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/style/app_colors.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sparkles above the text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSparkle(),
            const SizedBox(width: 8),
            _buildSparkle(),
            const SizedBox(width: 8),
            _buildSparkle(),
          ],
        ),
        const SizedBox(height: 12),
        // Arabic text "يقين"
        const Text(
          'يقين',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
            fontFamily: 'Tajawal',
            height: 1.2,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        // Book icon below the text
        Icon(
          Icons.menu_book_rounded,
          size: 32,
          color: AppColors.textWhite.withValues(alpha: 0.9),
        ),
      ],
    );
  }

  Widget _buildSparkle() {
    return Icon(
      Icons.star,
      size: 12,
      color: AppColors.textWhite.withValues(alpha: 0.8),
    );
  }
}

