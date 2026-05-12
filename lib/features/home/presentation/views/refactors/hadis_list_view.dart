import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_service.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/utils/spacing.dart';

class HadisListView extends StatefulWidget {
  const HadisListView({super.key});

  @override
  State<HadisListView> createState() => _HadisListViewState();
}

class _HadisListViewState extends State<HadisListView> {
  HadithModel? currentHadith;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHadith();
  }

  Future<void> _loadHadith() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final hadith = await HadithService.fetchRandomHadith();
      setState(() {
        currentHadith = hadith;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading hadith: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'فشل تحميل الحديث';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null || currentHadith == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[600],
            ),
            verticalSpace(16),
            Text(
              errorMessage ?? 'حدث خطأ في تحميل الحديث',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            verticalSpace(16),
            ElevatedButton(
              onPressed: _loadHadith,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Book name badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${currentHadith!.bookName} - رقم ${currentHadith!.refNo}',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                  verticalSpace(16),

                  // Chapter name
                  if (currentHadith!.chapter.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        currentHadith!.chapter,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Tajawal',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),

                  // Arabic hadith text
                  Divider(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    thickness: 1,
                    height: 16,
                  ),
                  verticalSpace(16),
                  Text(
                    currentHadith!.arabicText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Amiri',
                      height: 2.0,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  verticalSpace(20),

                  // English translation
                  if (currentHadith!.englishText.isNotEmpty) ...[
                    Divider(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      thickness: 1,
                      height: 16,
                    ),
                    verticalSpace(16),
                    Text(
                      currentHadith!.englishText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],

                  verticalSpace(24),

                  // Next hadith button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loadHadith,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, color: Colors.white),
                          horizontalSpace(8),
                          const Text(
                            'حديث آخر',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          verticalSpace(24),
        ],
      ),
    );
  }
}
