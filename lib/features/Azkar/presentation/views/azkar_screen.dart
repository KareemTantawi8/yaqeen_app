import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/Azkar/presentation/views/widgets/askar_image_banner.dart';
import 'package:yaqeen_app/features/Azkar/presentation/views/widgets/askar_list_view.dart';
import 'package:yaqeen_app/features/Azkar/presentation/views/widgets/azkar_app_bar_widget.dart';

import '../../../../core/common/widgets/custom_divider_widget.dart';
import '../../../../core/utils/spacing.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AzkarAppBarWidget(),
                verticalSpace(6),
                const CustomDividerWidget(),
                verticalSpace(6),
                const AzkarImageBanner(),
                verticalSpace(8),
                const AskarListView(),
                verticalSpace(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
