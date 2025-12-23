import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/refactors/related_hadis_list_view.dart';

import '../../../../core/common/widgets/custom_divider_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/utils/spacing.dart';

class RelatedHadisScreen extends StatelessWidget {
  const RelatedHadisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            children: [
              const DefaultAppBar(
                title: 'صحيح مسلم',
                icon: Icons.arrow_back,
              ),
              verticalSpace(5),
              const CustomDividerWidget(),
              verticalSpace(10),
              const Expanded(
                child: RelatedHadisListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
