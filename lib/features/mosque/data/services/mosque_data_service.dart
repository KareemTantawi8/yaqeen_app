import 'dart:math' as math;
import 'package:yaqeen_app/features/mosque/data/models/mosque_model.dart';

class MosqueDataService {
  static Future<List<MosqueModel>> getNearbyMosques({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  static double haversineKm(
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
