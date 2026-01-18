import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/utils/spacing.dart';

/// Secondary Tab: Word-by-word / Grammar tools
/// Features: Word-by-word analysis, Root words, Grammar rules, Pronunciation guides
class QuranWordByWordTab extends StatelessWidget {
  const QuranWordByWordTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.format_textdirection_r_to_l,
                size: 64,
                color: AppColors.primaryColor,
              ),
            ),
            verticalSpace(24),
            Text(
              'كلمة بكلمة',
              style: TextStyles.font24PrimaryText.copyWith(
                fontFamily: FontFamilyHelper.fontFamily1,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpace(12),
            Text(
              'قريباً: تحليل كلمة بكلمة مع قواعد النحو والصرف',
              style: TextStyles.font16PrimaryText.copyWith(
                fontFamily: FontFamilyHelper.fontFamily1,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

