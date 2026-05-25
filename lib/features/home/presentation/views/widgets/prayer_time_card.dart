import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    super.key,
    required this.prayer,
    required this.image,
    required this.time,
    this.isHighlighted = false,
  });

  final String prayer;
  final String image;
  final String time;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: isHighlighted ? 72 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prayer name
          Text(
            prayer,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.white70,
              fontSize: isHighlighted ? 13 : 11,
              fontFamily: 'Tajawal',
              fontWeight:
                  isHighlighted ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          // Icon
          Image.asset(
            image,
            width: isHighlighted ? 34 : 28,
            height: isHighlighted ? 34 : 28,
          ),
          const SizedBox(height: 8),
          // Time
          Text(
            time,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.white70,
              fontSize: isHighlighted ? 13 : 11,
              fontFamily: 'Tajawal',
              fontWeight:
                  isHighlighted ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          if (isHighlighted) ...[
            const SizedBox(height: 6),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
