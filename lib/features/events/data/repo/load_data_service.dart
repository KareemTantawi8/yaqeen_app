import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/islam_event_model.dart';

class EventLoader {
  static Future<List<IslamicEvent>> loadEventsFromJson() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/islamic_events_2025.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => IslamicEvent.fromJson(e)).toList();
  }
}
