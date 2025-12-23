import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/refactors/hadis_list_view.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/ahadis_app_bar_widget.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/haddis_banner_Widget.dart';

import '../../../../core/utils/spacing.dart';

class AhadisScreen extends StatelessWidget {
  const AhadisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const AhadisAppBarWidget(),
              verticalSpace(16),
              const HadisBannerWidget(),
              verticalSpace(16),
              Expanded(child: HadisListView()),
            ],
          ),
        ),
      ),
    );
  }
}
