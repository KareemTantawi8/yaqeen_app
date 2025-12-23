import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/launch_utils.dart';
import '../../../data/models/islam_event_model.dart';
import '../../../data/repo/load_data_service.dart';
import 'event_widget.dart';

class EventsListView extends StatefulWidget {
  const EventsListView({super.key});

  @override
  State<EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> {
  late Future<List<IslamicEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventLoader.loadEventsFromJson();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IslamicEvent>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ أثناء تحميل الأحداث.'));
        }

        final events = snapshot.data!;
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF9F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: EventWidget(
                    title: event.title,
                    date: event.date,
                    description: event.description,
                    onTap: () => launchExternalUrl(event.link, context),
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
