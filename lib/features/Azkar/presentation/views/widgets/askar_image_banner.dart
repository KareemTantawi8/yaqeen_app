import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';

class AzkarImageBanner extends StatelessWidget {
  const AzkarImageBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Image.asset(
            AppImages.askarHelperImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.primaryColor.withOpacity(0.65), // 🟦 شفافية اللون
          ),
          child: const Center(
            child: Text(
              'الَّذِينَ يَذْكُرُونَ اللَّهَ قِيَامًا وَقُعُودًا وَعَلَىٰ جُنُوبِهِمْوَيَتَفَكَّرُونَ\n فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFBFDFD) /* bgCOlor */,
                fontSize: 16,
                fontFamily: 'Amiri Quran',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
