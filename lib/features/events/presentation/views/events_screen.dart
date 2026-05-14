import 'package:flutter/material.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';
import 'widgets/events_list_view.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const DefaultAppBar(
                title: 'المناسبات الإسلامية',
                icon: Icons.arrow_back,
              ),
              verticalSpace(8),
              // Hijri year info strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, Color(0xFF1E6B5E)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _hijriYearLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace(12),
              const Expanded(child: EventsListView()),
            ],
          ),
        ),
      ),
    );
  }

  String _hijriYearLabel() {
    // Approximate current Hijri year from Gregorian
    final now = DateTime.now();
    final approxHijri = ((now.year - 622) * 1.030684).floor();
    return 'السنة الهجرية $approxHijri هـ  •  ${now.year} م';
  }
}
