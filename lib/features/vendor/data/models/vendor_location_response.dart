/// Response model for vendor location update API
class VendorLocationResponse {
  final bool success;
  final String message;
  final VendorLocationData? data;

  VendorLocationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory VendorLocationResponse.fromJson(Map<String, dynamic> json) {
    return VendorLocationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VendorLocationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VendorLocationData {
  final double latitude;
  final double longitude;
  final String? googleMapsUrl;

  VendorLocationData({
    required this.latitude,
    required this.longitude,
    this.googleMapsUrl,
  });

  factory VendorLocationData.fromJson(Map<String, dynamic> json) {
    return VendorLocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      googleMapsUrl: json['google_maps_url'] as String?,
    );
  }
}
