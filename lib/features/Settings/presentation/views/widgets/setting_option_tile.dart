import 'package:flutter/material.dart';

import '../../../../../core/extension/context_extension.dart';
import '../../../../../core/styles/colors/app_color.dart';

class SettingToggleTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final double? iconSize;
  final bool isActive;

  const SettingToggleTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
    this.iconSize = 40,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: ShapeDecoration(
          color: context.lightAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: context.brandText,
                fontSize: 20,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                icon,
                key: ValueKey(icon),
                color: AppColors.primaryColor,
                size: iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
