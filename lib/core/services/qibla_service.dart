import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';

class QiblaService {
  // Kaaba coordinates in Mecca (for reference/documentation)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla direction using adhan_dart's static method
  static double calculateQiblaDirection(double userLat, double userLng) {
    try {
      final coordinates = Coordinates(userLat, userLng);
      return Qibla.qibla(coordinates);
    } catch (e) {
      return 0.0; // Fallback to North if calculation fails
    }
  }

  /// Calculate distance to Kaaba in kilometers
  static double calculateDistanceToKaaba(double userLat, double userLng) {
    return Geolocator.distanceBetween(
      userLat,
      userLng,
      kaabaLatitude,
      kaabaLongitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Format distance with appropriate unit
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} م';
    } else if (distanceKm < 100) {
      return '${distanceKm.toStringAsFixed(1)} كم';
    } else {
      return '${distanceKm.toStringAsFixed(0)} كم';
    }
  }
}
