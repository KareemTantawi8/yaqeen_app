class MosqueModel {
  final String placeId;
  final String name;
  final double latitude;
  final double longitude;
  final double? rating;
  final bool? isOpen;
  final String? vicinity; // address
  final String? phoneNumber;
  final double distanceKm;
  final List<String>? types;
  final String? openingHours;

  MosqueModel({
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

  factory MosqueModel.fromJson(Map<String, dynamic> json, double userLat, double userLng) {
    final lat = json['geometry']['location']['lat'] as double;
    final lng = json['geometry']['location']['lng'] as double;

    return MosqueModel(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      latitude: lat,
      longitude: lng,
      rating: (json['rating'] as num?)?.toDouble(),
      isOpen: json['opening_hours']?['open_now'] as bool?,
      vicinity: json['vicinity'] as String?,
      types: List<String>.from(json['types'] as List? ?? []),
      distanceKm: _calculateDistance(userLat, userLng, lat, lng),
    );
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        Math.cos((lat2 - lat1) * p) / 2 +
        Math.cos(lat1 * p) *
            Math.cos(lat2 * p) *
            (1 - Math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * Math.asin(Math.sqrt(a)); // 2 * R; R = 6371 km
  }
}

// Simple Math class since we can't use dart:math in models
class Math {
  static const double PI = 3.141592653589793;

  static double cos(double x) {
    return _cos(x);
  }

  static double sin(double x) {
    return _sin(x);
  }

  static double sqrt(double x) {
    if (x < 0) return 0;
    if (x == 0) return 0;
    double guess = x;
    double prev;
    do {
      prev = guess;
      guess = (guess + x / guess) / 2;
    } while ((guess - prev).abs() > 1e-10);
    return guess;
  }

  static double asin(double x) {
    if (x > 1) x = 1;
    if (x < -1) x = -1;
    return _atan(x / sqrt(1 - x * x));
  }

  static double _cos(double x) {
    x = x % (2 * PI);
    if (x < 0) x += 2 * PI;
    if (x > PI) x = 2 * PI - x;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i < 100; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
      if (term.abs() < 1e-10) break;
    }
    return result;
  }

  static double _sin(double x) {
    x = x % (2 * PI);
    if (x < 0) x += 2 * PI;
    if (x > PI) x = 2 * PI - x;
    double result = x;
    double term = x;
    for (int i = 1; i < 100; i++) {
      term *= -x * x / ((2 * i + 1) * (2 * i));
      result += term;
      if (term.abs() < 1e-10) break;
    }
    return result;
  }

  static double _atan(double x) {
    double result = 0;
    double xPower = x;
    for (int i = 0; i < 100; i++) {
      result += xPower / (2 * i + 1);
      xPower *= -x * x * (2 * i + 1) / (2 * i + 3);
      if (xPower.abs() < 1e-10) break;
    }
    return result;
  }
}
