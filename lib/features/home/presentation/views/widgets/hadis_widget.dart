import 'package:flutter/material.dart';

import '../../../../../core/extension/context_extension.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class HadisWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String enTitle;
  final String num;
  void Function()? onTap;
  HadisWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.enTitle,
    required this.num,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0x59BBC4CE),
              width: 1.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    num,
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
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.highText,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    verticalSpace(4),
                    Opacity(
                      opacity: 0.80,
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: context.secondaryText,
                          fontSize: 14,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                enTitle,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: context.secondaryText,
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
