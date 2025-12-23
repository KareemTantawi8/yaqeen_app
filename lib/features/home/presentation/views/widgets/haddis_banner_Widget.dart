
import 'package:flutter/material.dart';

import '../../../../../core/styles/images/app_image.dart';

class HadisBannerWidget extends StatelessWidget {
  const HadisBannerWidget({
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
            AppImages.hadisBannerWidget,
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
            color: const Color(0xFF2B7669).withOpacity(0.7), // 🟦 شفافية اللون
          ),
          child: const Center(
            child: Text(
              ' وَمَا يَنْطِقُ عَنِ الْهَوَى إِنْ هُوَ إِلَّا وَحْيٌ يُوحَى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFBFDFD) /* bgCOlor */,
                fontSize: 20,
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
