import 'dart:convert';
import '../../../../core/services/network/api/api_consumer.dart';
import '../../../../core/services/network/api/api_endpoints.dart';
import '../../../../core/services/service_locator.dart';
import '../models/islam_event_model.dart';

class EventLoader {
  static Future<List<IslamicEvent>> loadEventsFromJson() async {
    try {
      final apiConsumer = getIt<ApiConsumer>();
      final response = await apiConsumer.get(EndPoints.getIslamicEvents);
      
      // Handle different response formats
      List<dynamic> jsonList;
      if (response is List) {
        jsonList = response;
      } else if (response is Map && response.containsKey('data')) {
        jsonList = response['data'] as List;
      } else if (response is Map && response.containsKey('events')) {
        jsonList = response['events'] as List;
      } else {
        jsonList = [response];
      }
      
      return jsonList.map((e) => IslamicEvent.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback: Return empty list or handle error as needed
      throw Exception('Failed to load events: $e');
    }
  }
}
