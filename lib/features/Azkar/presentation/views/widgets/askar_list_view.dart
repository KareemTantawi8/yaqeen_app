import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/model/askar_model.dart';
import '../../../data/repo/askar_load_data.dart';
import 'askar_widget.dart';
// Adjust import path as needed

class AskarListView extends StatelessWidget {
  const AskarListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Azkar>>(
      future: AzkarService.loadAzkar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading indicator while data loads
          return const Center(
              child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ));
        } else if (snapshot.hasError) {
          // Error UI
          return Center(child: Text('Error loading Azkar: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Empty state UI
          return const Center(child: Text('No Azkar available'));
        }

        // Data loaded successfully
        final azkarList = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, // <--- Important
          physics: NeverScrollableScrollPhysics(),
          itemCount: azkarList.length,
          padding: const EdgeInsets.only(top: 8),
          itemBuilder: (context, index) {
            final azkar = azkarList[index];
            return AzkarWidget(
              title: azkar.title,
              number: "${index + 1}",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
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
                              azkar.title,
                              style: TextStyles.font24WhiteText.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          verticalSpace(12),
                          Text(
                            azkar.content,
                            textAlign: TextAlign.center,
                            style: TextStyles.font20PrimaryText.copyWith(
                              letterSpacing: 0.40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
