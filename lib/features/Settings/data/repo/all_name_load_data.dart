import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/services/service_locator.dart';
import '../models/allah_name_model.dart';

class AllNamesLoadData {
  static Future<List<AllahNameModel>> loadFromAssets() async {
    try {
      final dio = getIt<Dio>();
      // Use external API endpoint directly
      final response = await dio.get('https://api.aladhan.com/v1/asmaAlHusna');
      
      // Handle API response format: {code: 200, status: "OK", data: [...]}
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final jsonList = responseData['data'] as List;
          return jsonList
              .map((e) => AllahNameModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Invalid API response format: data field not found or not a list');
        }
      } else {
        throw Exception('Invalid API response format: expected Map');
      }
    } catch (e) {
      throw Exception('Failed to load Allah names: $e');
    }
  }
}
