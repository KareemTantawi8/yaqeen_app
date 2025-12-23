import 'dart:convert';
import '../../../../core/services/network/api/api_consumer.dart';
import '../../../../core/services/network/api/api_endpoints.dart';
import '../../../../core/services/service_locator.dart';
import '../models/surah_model.dart';

class QuranDataLoader {
  static Future<List<Surah>> loadSurahs() async {
    try {
      final apiConsumer = getIt<ApiConsumer>();
      final response = await apiConsumer.get(EndPoints.getSurahs);
      
      // Handle different response formats
      List<dynamic> jsonList;
      if (response is List) {
        jsonList = response;
      } else if (response is Map && response.containsKey('data')) {
        jsonList = response['data'] as List;
      } else if (response is Map && response.containsKey('surahs')) {
        jsonList = response['surahs'] as List;
      } else {
        jsonList = [response];
      }
      
      return jsonList.map((json) => Surah.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback: Return empty list or handle error as needed
      throw Exception('Failed to load surahs: $e');
    }
  }
}
