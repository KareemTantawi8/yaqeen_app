import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _keyLatitude = 'last_latitude';
  static const String _keyLongitude = 'last_longitude';
  
  // Default location (Riyadh, Saudi Arabia)
  static const double defaultLatitude = 24.7406086;
  static const double defaultLongitude = 46.8060108;

  /// Get current location with permission handling
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      // Save location to preferences
      await _saveLocation(position.latitude, position.longitude);
      
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Get location with fallback to saved or default location
  static Future<Map<String, double>> getLocationWithFallback() async {
    try {
      // Try to get current location
      final position = await getCurrentLocation();
      
      if (position != null) {
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }

      // Fallback to saved location
      final savedLocation = await getSavedLocation();
      if (savedLocation != null) {
        debugPrint('Using saved location');
        return savedLocation;
      }

      // Fallback to default location
      debugPrint('Using default location (Riyadh)');
      return {
        'latitude': defaultLatitude,
        'longitude': defaultLongitude,
      };
    } catch (e) {
      debugPrint('Error in getLocationWithFallback: $e');
      return {
        'latitude': defaultLatitude,
        'longitude': defaultLongitude,
      };
    }
  }

  /// Save location to SharedPreferences
  static Future<void> _saveLocation(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyLatitude, latitude);
      await prefs.setDouble(_keyLongitude, longitude);
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  /// Get saved location from SharedPreferences
  static Future<Map<String, double>?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble(_keyLatitude);
      final longitude = prefs.getDouble(_keyLongitude);
      
      if (latitude != null && longitude != null) {
        return {
          'latitude': latitude,
          'longitude': longitude,
        };
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting saved location: $e');
      return null;
    }
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Open app settings for location permission
  static Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Show location permission dialog
  static Future<bool> showLocationPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'إذن الموقع',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'نحتاج إلى موقعك لعرض أوقات الصلاة الدقيقة لمنطقتك.\n\nإذا رفضت، سنستخدم الموقع الافتراضي (الرياض).',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Tajawal',
              height: 1.6,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'استخدام الموقع الافتراضي',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'السماح',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Get location description for UI
  static String getLocationDescription(double latitude, double longitude) {
    if (latitude == defaultLatitude && longitude == defaultLongitude) {
      return 'الرياض، السعودية';
    }
    return 'موقعك الحالي';
  }
}

