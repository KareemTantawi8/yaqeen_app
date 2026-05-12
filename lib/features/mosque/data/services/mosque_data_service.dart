import 'package:yaqeen_app/features/mosque/data/models/mosque_model.dart';

class MosqueDataService {
  /// Offline mosque database - Popular mosques with approximate coordinates
  static final List<Map<String, dynamic>> _mosqueDatabase = [
    {
      'placeId': 'mosque_001',
      'name': 'المسجد الحرام',
      'latitude': 21.4225,
      'longitude': 39.8262,
      'rating': 4.8,
      'isOpen': true,
      'vicinity': 'مكة المكرمة، السعودية',
      'phoneNumber': '+966-12-5556666',
    },
    {
      'placeId': 'mosque_002',
      'name': 'المسجد النبوي',
      'latitude': 24.4539,
      'longitude': 39.5894,
      'rating': 4.9,
      'isOpen': true,
      'vicinity': 'المدينة المنورة، السعودية',
      'phoneNumber': '+966-14-8145555',
    },
    {
      'placeId': 'mosque_003',
      'name': 'المسجد الأقصى',
      'latitude': 31.7683,
      'longitude': 35.2137,
      'rating': 4.7,
      'isOpen': true,
      'vicinity': 'القدس، فلسطين',
      'phoneNumber': '+970-2-6271500',
    },
    {
      'placeId': 'mosque_004',
      'name': 'مسجد السلطان أحمد',
      'latitude': 41.0054,
      'longitude': 28.9768,
      'rating': 4.6,
      'isOpen': true,
      'vicinity': 'إسطنبول، تركيا',
      'phoneNumber': '+90-212-5189393',
    },
    {
      'placeId': 'mosque_005',
      'name': 'مسجد الفتح',
      'latitude': 30.0644,
      'longitude': 31.2454,
      'rating': 4.5,
      'isOpen': true,
      'vicinity': 'القاهرة، مصر',
      'phoneNumber': '+20-2-23649555',
    },
    {
      'placeId': 'mosque_006',
      'name': 'المسجد الجامع الكبير',
      'latitude': 33.3128,
      'longitude': 44.3615,
      'rating': 4.4,
      'isOpen': true,
      'vicinity': 'بغداد، العراق',
      'phoneNumber': '+964-1-7166666',
    },
    {
      'placeId': 'mosque_007',
      'name': 'مسجد الملك فهد',
      'latitude': 48.8725,
      'longitude': 2.2865,
      'rating': 4.3,
      'isOpen': true,
      'vicinity': 'باريس، فرنسا',
      'phoneNumber': '+33-1-43659989',
    },
    {
      'placeId': 'mosque_008',
      'name': 'مسجد الدرس الحسني',
      'latitude': 33.9716,
      'longitude': -6.8498,
      'rating': 4.2,
      'isOpen': true,
      'vicinity': 'الرباط، المغرب',
      'phoneNumber': '+212-5-37734567',
    },
    {
      'placeId': 'mosque_009',
      'name': 'مسجد الملك فهد',
      'latitude': 25.2048,
      'longitude': 55.2708,
      'rating': 4.5,
      'isOpen': true,
      'vicinity': 'دبي، الإمارات',
      'phoneNumber': '+971-4-3228555',
    },
    {
      'placeId': 'mosque_010',
      'name': 'المسجد الكبير',
      'latitude': 35.0781,
      'longitude': 6.6147,
      'rating': 4.3,
      'isOpen': true,
      'vicinity': 'الجزائر، الجزائر',
      'phoneNumber': '+213-21-4346666',
    },
  ];

  /// Get nearby mosques filtered by radius
  static Future<List<MosqueModel>> getNearbyMosques({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final radiusKm = radiusMeters / 1000;

    final mosques = _mosqueDatabase
        .map((mosque) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            mosque['latitude'] as double,
            mosque['longitude'] as double,
          );

          return MosqueModel(
            placeId: mosque['placeId'] as String,
            name: mosque['name'] as String,
            latitude: mosque['latitude'] as double,
            longitude: mosque['longitude'] as double,
            rating: mosque['rating'] as double?,
            isOpen: mosque['isOpen'] as bool?,
            vicinity: mosque['vicinity'] as String?,
            phoneNumber: mosque['phoneNumber'] as String?,
            distanceKm: distance,
          );
        })
        .where((mosque) => mosque.distanceKm <= radiusKm)
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return mosques;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        _cos((lat2 - lat1) * p) / 2 +
        _cos(lat1 * p) *
            _cos(lat2 * p) *
            (1 - _cos((lon2 - lon1) * p)) /
            2;
    return 12742 * _asin(_sqrt(a));
  }

  static double _cos(double x) {
    x = x % (2 * 3.141592653589793);
    if (x < 0) x += 2 * 3.141592653589793;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i < 100; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
      if (term.abs() < 1e-10) break;
    }
    return result;
  }

  static double _sqrt(double x) {
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

  static double _asin(double x) {
    if (x > 1) x = 1;
    if (x < -1) x = -1;
    return _atan(x / _sqrt(1 - x * x));
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
