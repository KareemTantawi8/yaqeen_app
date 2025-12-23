import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/azkar_card.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/maspha_widget.dart';

import '../../../../core/common/widgets/custom_divider_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

class MesphaScreen extends StatelessWidget {
  static const String routeName = '/mespha';
  const MesphaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.boldText,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DefaultAppBar(
                    title: 'المسبحة',
                    icon: Icons.arrow_back,
                  ),
                  verticalSpace(4),
                  const CustomDividerWidget(),
                  verticalSpace(16),
                  const AzkarCard(),
                ],
              ),
            ),
            verticalSpace(20),
            const Expanded(
              child: MesphaWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
