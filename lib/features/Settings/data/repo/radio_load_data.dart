import 'package:dio/dio.dart';
import '../../../../core/services/service_locator.dart';
import '../models/radio_model.dart';

class RadioLoadData {
  static Future<RadioResponse> loadRadios() async {
    try {
      final dio = getIt<Dio>();
      final url = 'https://mp3quran.net/api/radio/radio_ar.json';
      
      final response = await dio.get(url);
      
      if (response.data is Map<String, dynamic>) {
        return RadioResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid API response format: expected Map');
      }
    } catch (e) {
      throw Exception('Failed to load radios: $e');
    }
  }
}

