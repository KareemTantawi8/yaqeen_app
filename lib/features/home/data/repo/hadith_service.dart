import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/hadith_model.dart';

class HadithService {
  static const String apiUrl =
      'https://random-hadith-generator.vercel.app/bukhari/';

  /// Fetch a random hadith from the API
  static Future<HadithModel> fetchRandomHadith() async {
    try {
      debugPrint('Fetching random hadith from: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Hadith API response: $data');

        return HadithModel.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load hadith: Status code ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching hadith: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Failed to load hadith: $e');
    }
  }
}
