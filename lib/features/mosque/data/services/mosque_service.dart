import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yaqeen_app/features/mosque/data/models/mosque_model.dart';

/// Uses OpenStreetMap's Overpass API — free, no API key, no billing required.
class MosqueService {
  // Multiple mirrors so if one is down or rate-limits, we try the next
  static const List<String> _mirrors = [
    'https://overpass.openstreetmap.fr/api/interpreter',
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  static final Map<String, String> _headers = {
    'User-Agent': 'YaqeenApp/1.0 (Islamic prayer and mosque finder)',
    'Accept': 'application/json',
  };

  static Future<List<MosqueModel>> getNearbyMosques({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    final radius = radiusMeters.toInt();
    final query =
        '[out:json][timeout:15];'
        '(nwr["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$radius,$latitude,$longitude);'
        'nwr["amenity"="mosque"]'
        '(around:$radius,$latitude,$longitude);'
        ');out center;';

    debugPrint('MosqueService: querying ${radius}m around $latitude,$longitude');

    String? lastError;
    for (int i = 0; i < _mirrors.length; i++) {
      final url = _mirrors[i];
      // Short pause between mirror attempts to avoid rate-limit cascading
      if (i > 0) await Future.delayed(const Duration(milliseconds: 800));

      try {
        // POST with Map<String,String> body — Dart http package automatically
        // URL-encodes the values and sets Content-Type: application/x-www-form-urlencoded
        final response = await http
            .post(
              Uri.parse(url),
              headers: _headers,
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 22));

        debugPrint(
            'MosqueService: $url → HTTP ${response.statusCode}, '
            '${response.body.length} bytes');

        if (response.statusCode == 429) {
          debugPrint('MosqueService: rate-limited by $url, trying next');
          lastError = 'rate limited (429)';
          continue;
        }
        if (response.statusCode != 200) {
          debugPrint('MosqueService: body preview → '
              '${response.body.substring(0, math.min(200, response.body.length))}');
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final elements = (json['elements'] as List?) ?? [];

        final seen = <String>{};
        final mosques = <MosqueModel>[];
        for (final el in elements) {
          final m = _parse(el as Map<String, dynamic>, latitude, longitude);
          if (m != null && seen.add('${m.latitude},${m.longitude}')) {
            mosques.add(m);
          }
        }

        mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        debugPrint('MosqueService: found ${mosques.length} mosques');
        return mosques;
      } catch (e) {
        debugPrint('MosqueService: $url error → $e');
        lastError = e.toString();
      }
    }

    throw Exception(lastError ?? 'All Overpass mirrors failed');
  }

  static MosqueModel? _parse(
      Map<String, dynamic> el, double userLat, double userLng) {
    try {
      final tags = el['tags'] as Map<String, dynamic>? ?? {};
      final name = (tags['name:ar'] as String?) ??
          (tags['name'] as String?) ??
          (tags['name:en'] as String?);
      if (name == null || name.isEmpty) return null;

      double? lat, lng;
      if (el['type'] == 'node') {
        lat = (el['lat'] as num?)?.toDouble();
        lng = (el['lon'] as num?)?.toDouble();
      } else {
        final c = el['center'] as Map<String, dynamic>?;
        lat = (c?['lat'] as num?)?.toDouble();
        lng = (c?['lon'] as num?)?.toDouble();
      }
      if (lat == null || lng == null) return null;

      final parts = <String>[
        if (tags['addr:street'] != null) tags['addr:street'] as String,
        if (tags['addr:district'] != null) tags['addr:district'] as String,
        if (tags['addr:city'] != null) tags['addr:city'] as String,
      ];

      return MosqueModel(
        placeId: '${el['type']}_${el['id']}',
        name: name,
        latitude: lat,
        longitude: lng,
        vicinity: parts.isEmpty ? null : parts.join('، '),
        distanceKm: _haversineKm(userLat, userLng, lat, lng),
      );
    } catch (_) {
      return null;
    }
  }

  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const p = math.pi / 180;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }
}
