import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/utils/spacing.dart';

/// Secondary Tab: Translations
/// Features: Multiple language translations, Side-by-side comparison, Translation search
class QuranTranslationsTab extends StatelessWidget {
  const QuranTranslationsTab({super.key});

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
                Icons.translate_outlined,
                size: 64,
                color: AppColors.primaryColor,
              ),
            ),
            verticalSpace(24),
            Text(
              'الترجمات',
              style: TextStyles.font24PrimaryText.copyWith(
                fontFamily: FontFamilyHelper.fontFamily1,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpace(12),
            Text(
              'قريباً: سيتم إضافة ترجمات القرآن بعدة لغات',
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

