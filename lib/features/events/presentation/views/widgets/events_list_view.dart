import 'package:flutter/material.dart';
import '../../../../../core/common/widgets/launch_utils.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../data/models/islam_event_model.dart';
import '../../../data/repo/load_data_service.dart';

class EventsListView extends StatefulWidget {
  const EventsListView({super.key});

  @override
  State<EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> {
  late Future<List<IslamicEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = EventLoader.loadEventsFromJson();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IslamicEvent>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد مناسبات متاحة',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, color: AppColors.primaryColor),
            ),
          );
        }

        final events = snapshot.data!;
        final now = DateTime.now();

        // Split into upcoming and past (past 7 days)
        final upcoming = <IslamicEvent>[];
        final past = <IslamicEvent>[];
        for (final ev in events) {
          // Detect past events by checking the status text in date field
          if (ev.date.contains('مرّ منذ')) {
            past.add(ev);
          } else {
            upcoming.add(ev);
          }
        }

        return ListView(
          children: [
            if (upcoming.isNotEmpty) ...[
              _SectionHeader(title: 'القادمة', icon: Icons.upcoming_outlined),
              const SizedBox(height: 8),
              ...upcoming.map((e) => _EventCard(event: e, isPast: false)),
            ],
            if (past.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'المنصرمة', icon: Icons.history_outlined),
              const SizedBox(height: 8),
              ...past.map((e) => _EventCard(event: e, isPast: true)),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.primaryColor, thickness: 0.5)),
        const SizedBox(width: 10),
        Icon(icon, color: AppColors.primaryColor, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppColors.primaryColor, thickness: 0.5)),
      ],
    );
  }
}

class _EventCard extends StatefulWidget {
  final IslamicEvent event;
  final bool isPast;
  const _EventCard({required this.event, required this.isPast});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _expanded = false;

  Color get _accent => widget.isPast
      ? Colors.grey.shade500
      : AppColors.primaryColor;

  @override
  Widget build(BuildContext context) {
    // Detect "today" from date field
    final isToday = widget.event.date.contains('اليوم');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? const Color(0xFFFFD700)
                : _accent.withOpacity(widget.isPast ? 0.2 : 0.5),
            width: isToday ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header row ──────────────────────────────────────────
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Expand/collapse icon
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _expanded ? 0.25 : 0,
                      child: Icon(Icons.chevron_right_rounded,
                          color: _accent, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isToday)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'اليوم',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Tajawal',
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              Flexible(
                                child: Text(
                                  widget.event.title,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: widget.isPast
                                        ? Colors.grey.shade600
                                        : const Color(0xFF1A2221),
                                    fontSize: 15,
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.event.date,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: _accent.withOpacity(0.85),
                              fontSize: 11,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Event icon
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_eventIcon(widget.event.title),
                          color: _accent, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            // ── Expanded body ────────────────────────────────────────
            if (_expanded)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9F8),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.event.description,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Tajawal',
                        color: Color(0xFF2D4A47),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => launchExternalUrl(widget.event.link, context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'معرفة المزيد',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _eventIcon(String title) {
    if (title.contains('رمضان')) return Icons.nightlight_round;
    if (title.contains('عيد الفطر')) return Icons.celebration_outlined;
    if (title.contains('عيد الأضحى')) return Icons.mosque_outlined;
    if (title.contains('عاشوراء')) return Icons.water_drop_outlined;
    if (title.contains('المولد')) return Icons.auto_awesome_outlined;
    if (title.contains('الإسراء') || title.contains('المعراج')) return Icons.star_outline;
    if (title.contains('القدر')) return Icons.brightness_3_outlined;
    if (title.contains('عرفة')) return Icons.landscape_outlined;
    if (title.contains('السنة الهجرية')) return Icons.calendar_today_outlined;
    if (title.contains('التشريق')) return Icons.wb_sunny_outlined;
    if (title.contains('شعبان')) return Icons.nights_stay_outlined;
    return Icons.event_outlined;
  }
}
