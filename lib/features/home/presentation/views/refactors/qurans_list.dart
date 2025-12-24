import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repo/quran_data_loader.dart';
import '../surah_detail_screen.dart';

class QuransList extends StatelessWidget {
  const QuransList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Surah>>(
      future: QuranDataLoader.loadSurahs(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                verticalSpace(16),
                const Text(
                  'جاري تحميل السور...',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
                // verticalSpace(1888),1888

              ],
            ),
          );
        }
        
        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),
                verticalSpace(16),
                Text(
                  'فشل تحميل السور',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                verticalSpace(8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Empty state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد سور متاحة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
              ),
            ),
          );
        }
        
        final surahs = snapshot.data!;
        return ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahDetailScreen(surah: surah),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
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
                            '${surah.number}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A2221),
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
                              surah.english,
                              style: const TextStyle(
                                color: Color(0xFF1A2221),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            verticalSpace(4),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFF6F8F87),
                                  fontSize: 14,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                                children: [
                                  TextSpan(text: '${surah.ayahs} آيات'),
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Color(0x59BBC4CE),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(text: surah.type),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        surah.arabic,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF2B7669),
                          fontSize: 22,
                          fontFamily: 'Amiri Quran',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ],
                  ),
                ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
