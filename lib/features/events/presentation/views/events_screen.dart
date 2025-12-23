import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/events/presentation/views/widgets/events_list_view.dart';

import '../../../../core/common/widgets/app_bar_widget.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.boldText,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const AppBarWidget(
                icon: Icons.calendar_month_outlined,
                title: 'المناسبات',
              ),
              verticalSpace(20),
              const Expanded(
                child: EventsListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
