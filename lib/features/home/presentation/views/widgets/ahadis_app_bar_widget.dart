
import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class AhadisAppBarWidget extends StatelessWidget {
  const AhadisAppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'الاحاديث الشريفة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF2B7669) /* Primarycolor */,
            fontSize: 24,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          height: 55,
          width: 55,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF9F4),
            shape: BoxShape.circle,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Image.asset(
              AppImages.saveIcon,
            ),
          ),
        ),
        horizontalSpace(5),
        Container(
          height: 55,
          width: 55,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF9F4),
            shape: BoxShape.circle,
          ),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Icon(
              Icons.arrow_back,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
