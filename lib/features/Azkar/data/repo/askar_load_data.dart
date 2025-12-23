import 'dart:convert';
import '../../../../core/services/network/api/api_consumer.dart';
import '../../../../core/services/network/api/api_endpoints.dart';
import '../../../../core/services/service_locator.dart';
import '../model/askar_model.dart';

class AzkarService {
  static Future<List<Azkar>> loadAzkar() async {
    try {
      final apiConsumer = getIt<ApiConsumer>();
      final response = await apiConsumer.get(EndPoints.getAzkar);
      
      // Handle different response formats
      List<dynamic> jsonList;
      if (response is List) {
        jsonList = response;
      } else if (response is Map && response.containsKey('data')) {
        jsonList = response['data'] as List;
      } else if (response is Map && response.containsKey('azkar')) {
        jsonList = response['azkar'] as List;
      } else {
        jsonList = [response];
      }
      
      return jsonList.map((json) => Azkar.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback: Return empty list or handle error as needed
      throw Exception('Failed to load azkar: $e');
    }
  }
}
