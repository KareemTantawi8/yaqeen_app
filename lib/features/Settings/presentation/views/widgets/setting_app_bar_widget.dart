import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class SettingAppBarWidget extends StatelessWidget {
  const SettingAppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Image(
          color: AppColors.primaryColor,
          height: 22,
          width: 22,
          image: AssetImage(AppImages.settingIcons),
        ),
        horizontalSpace(8),
        const Center(
          // This ensures vertical alignment with the image
          child: SizedBox(
            child: Text(
              'المزيد',
              style: TextStyle(
                color: Color(0xFF2B7669),
                fontSize: 24,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
