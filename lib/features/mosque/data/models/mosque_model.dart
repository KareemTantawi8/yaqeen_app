import 'dart:math' as math;

class MosqueModel {
  final String placeId;
  final String name;
  final double latitude;
  final double longitude;
  final double? rating;
  final bool? isOpen;
  final String? vicinity;
  final String? phoneNumber;
  final double distanceKm;
  final List<String>? types;
  final String? openingHours;

  const MosqueModel({
    required this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.isOpen,
    this.vicinity,
    this.phoneNumber,
    required this.distanceKm,
    this.types,
    this.openingHours,
  });

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
