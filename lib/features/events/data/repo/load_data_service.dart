import '../models/islam_event_model.dart';
import 'islamic_events_calculator.dart';

class EventLoader {
  static Future<List<IslamicEvent>> loadEventsFromJson() async {
    // Fully offline — no network required.
    // Calculates Islamic events for the current & next Hijri year.
    return IslamicEventsCalculator.getEvents();
  }
}
