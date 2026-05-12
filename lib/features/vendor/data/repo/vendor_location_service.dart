import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/network/api/api_consumer.dart';
import '../../../../core/services/network/api/api_endpoints.dart';
import '../../../../core/services/service_locator.dart';
import '../models/vendor_location_response.dart';

/// Service for updating vendor GPS location via API
class VendorLocationService {
  static const String _tokenKey = 'login_token';

  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  /// Update vendor's GPS location
  /// PUT /api/v1/profile/location
  /// Returns [VendorLocationResponse] on success
  static Future<VendorLocationResponse> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final apiConsumer = getIt<ApiConsumer>();
    final token = await _getToken();

    final response = await apiConsumer.put(
      EndPoints.updateVendorLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
      token: token ?? '',
    );

    if (response is Map<String, dynamic>) {
      return VendorLocationResponse.fromJson(response);
    }

    throw Exception('Invalid API response format');
  }
}
