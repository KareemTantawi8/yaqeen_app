import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/utils/spacing.dart';

class AllahNamesWidget extends StatelessWidget {
  const AllahNamesWidget({
    super.key,
    required this.title,
    required this.enTitle,
    required this.traTitle,
    required this.onTap,
    this.icon = Icons.play_arrow_outlined,
  });

  final String title;
  final String enTitle;
  final String traTitle;
  final void Function()? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.00, 0.50),
            end: Alignment(1.00, 0.50),
            colors: [Color(0xFFD3F9EC), Color(0xFFEAF9F4)],
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1A2221),
                        fontSize: 32,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    enTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A2221),
                      fontSize: 16,
                      fontFamily: FontFamilyHelper.fontFamily2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    traTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9AB1AB),
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: 0.10,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(16),
            Icon(
              icon,
              size: 36,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
