import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class AyahOfTheDayDialog extends StatelessWidget {
  const AyahOfTheDayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.boldText,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppImages.dialogImage,
            ),
            verticalSpace(12),
            Center(
              child: Text(
                'آية اليوم',
                style: TextStyles.font24WhiteText.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            verticalSpace(12),
            Text(
              '(وَٱذۡكُرِ ٱسۡمَ رَبِّكَ وَتَبَتَّلۡ إِلَیۡهِ تَبۡتِیلࣰا رَّبُّ ٱلۡمَشۡرِقِ وَٱلۡمَغۡرِبِ لَاۤ إِلَـٰهَ إِلَّا هُوَ فَٱتَّخِذۡهُ وَكِیلࣰا وَٱصۡبِرۡ عَلَىٰ مَا یَقُولُونَ وَٱهۡجُرۡهُمۡ هَجۡرࣰا جَمِیلࣰا). [المزمل: 8-10]',
              textAlign: TextAlign.center,
              style: TextStyles.font20PrimaryText.copyWith(
                letterSpacing: 0.40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
