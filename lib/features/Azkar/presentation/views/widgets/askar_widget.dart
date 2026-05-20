import 'package:flutter/material.dart';

import '../../../../../core/extension/context_extension.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

// ignore: must_be_immutable
class AzkarWidget extends StatelessWidget {
  AzkarWidget({
    super.key,
    required this.title,
    required this.number,
    required this.onTap,
  });

  final String title;
  final String number;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF9F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    AppImages.shape2Image,
                    width: 50,
                    height: 50,
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.highText,
                    ),
                  ),
                ],
              ),
              horizontalSpace(12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2B7669),
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: iconSize,
                color: const Color(0xFF2B7669),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
