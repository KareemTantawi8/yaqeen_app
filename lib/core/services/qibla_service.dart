import 'dart:math';
import 'package:geolocator/geolocator.dart';

class QiblaService {
  // Kaaba coordinates in Mecca
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla direction (angle from North) from user's location
  static double calculateQiblaDirection(double userLat, double userLng) {
    // Convert to radians
    final userLatRad = _degreesToRadians(userLat);
    final userLngRad = _degreesToRadians(userLng);
    final kaabaLatRad = _degreesToRadians(kaabaLatitude);
    final kaabaLngRad = _degreesToRadians(kaabaLongitude);

    // Calculate using spherical trigonometry
    final deltaLng = kaabaLngRad - userLngRad;

    final y = sin(deltaLng);
    final x = cos(userLatRad) * tan(kaabaLatRad) -
        sin(userLatRad) * cos(deltaLng);

    // Calculate angle (azimuth)
    double angle = atan2(y, x);
    
    // Convert to degrees
    angle = _radiansToDegrees(angle);
    
    // Normalize to 0-360
    angle = (angle + 360) % 360;

    return angle;
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

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  static double _radiansToDegrees(double radians) {
    return radians * 180 / pi;
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

