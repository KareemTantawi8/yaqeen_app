import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yaqeen_app/features/mosque/data/models/mosque_model.dart';

class MosqueService {
  static const String _apiKey = 'AIzaSyDVjB-dVk0Fy325gPWUaJGAbatgTSLD-PU';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// Get nearby mosques using Google Places Nearby Search API
  static Future<List<MosqueModel>> getNearbyMosques({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    try {
      final url =
          '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=${radiusMeters.toInt()}&type=mosque&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final results = json['results'] as List? ?? [];

        return results
            .map((result) =>
                MosqueModel.fromJson(result as Map<String, dynamic>, latitude, longitude))
            .toList()
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      } else {
        throw Exception('Failed to load nearby mosques: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching nearby mosques: $e');
    }
  }

  /// Get detailed information about a specific mosque
  static Future<MosqueModel?> getMosqueDetails(
    String placeId,
    double userLat,
    double userLng,
  ) async {
    try {
      const fields = 'name,formatted_phone_number,opening_hours,geometry,rating,types,vicinity';
      final url =
          '$_baseUrl/details/json?place_id=$placeId&fields=$fields&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = json['result'] as Map<String, dynamic>? ?? {};

        if (result.isEmpty) return null;

        final phoneNumber = result['formatted_phone_number'] as String?;
        final openingHours = result['opening_hours']?['weekday_text'] as List?;

        // Parse the result into MosqueModel
        final mosque = MosqueModel.fromJson(result, userLat, userLng);

        // Return enriched mosque with phone number
        return MosqueModel(
          placeId: mosque.placeId,
          name: mosque.name,
          latitude: mosque.latitude,
          longitude: mosque.longitude,
          rating: mosque.rating,
          isOpen: result['opening_hours']?['open_now'] as bool?,
          vicinity: mosque.vicinity,
          phoneNumber: phoneNumber,
          distanceKm: mosque.distanceKm,
          types: mosque.types,
          openingHours: openingHours?.join('\n'),
        );
      } else {
        throw Exception('Failed to get mosque details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching mosque details: $e');
    }
  }
}
