import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class AzkarAppBarWidget extends StatelessWidget {
  const AzkarAppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.azkarIcon,
              height: 24,
              width: 24,
              color: AppColors.primaryColor,
            ),
            horizontalSpace(8),
            const Text(
              'الادعية و الاذكار',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2B7669) /* Primarycolor */,
                fontSize: 24,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
