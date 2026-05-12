import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaqeen_app/core/services/location_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/mosque/data/models/mosque_model.dart';
import 'package:yaqeen_app/features/mosque/data/services/mosque_service.dart';

class MosqueMapScreen extends StatefulWidget {
  static const String routeName = '/mosque_map';

  const MosqueMapScreen({super.key});

  @override
  State<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends State<MosqueMapScreen> {
  late GoogleMapController _mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  MosqueModel? _selectedMosque;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  double _searchRadiusKm = 5.0;

  final List<double> _radiusOptions = [1.0, 3.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final location = await LocationService.getLocationWithFallback();
      final userLat = location['latitude'] as double;
      final userLng = location['longitude'] as double;

      setState(() {
        _userLocation = LatLng(userLat, userLng);
      });

      // Move map to user location
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userLat, userLng),
            zoom: 14,
          ),
        ),
      );

      // Load nearby mosques
      await _loadNearbyMosques();
    } catch (e) {
      debugPrint('Failed to initialize map: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'فشل تحميل الخريطة';
      });
    }
  }

  Future<void> _loadNearbyMosques() async {
    if (_userLocation == null) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
        _selectedMosque = null;
      });

      final mosques = await MosqueService.getNearbyMosques(
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        radiusMeters: _searchRadiusKm * 1000,
      );

      // Create markers
      final markers = <Marker>{};

      for (final mosque in mosques) {
        markers.add(
          Marker(
            markerId: MarkerId(mosque.placeId),
            position: LatLng(mosque.latitude, mosque.longitude),
            infoWindow: InfoWindow(
              title: mosque.name,
              snippet: '${mosque.distanceKm.toStringAsFixed(1)} كم',
            ),
            onTap: () {
              setState(() {
                _selectedMosque = mosque;
              });
            },
          ),
        );
      }

      // Add user location marker
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'موقعك الحالي'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );

      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load nearby mosques: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'فشل تحميل المساجد القريبة';
      });
    }
  }

  Future<void> _launchMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المساجد القريبة',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _userLocation ?? const LatLng(21.4225, 39.8262),
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      verticalSpace(16),
                      const Text(
                        'جاري تحميل المساجد...',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Error overlay
          if (_hasError && !_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      verticalSpace(12),
                      Text(
                        _errorMessage ?? 'حدث خطأ',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      verticalSpace(16),
                      ElevatedButton(
                        onPressed: _loadNearbyMosques,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Radius control - top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'نطاق البحث',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    '${_searchRadiusKm.toStringAsFixed(1)} كم',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  verticalSpace(8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _radiusOptions.map((radius) {
                        final isSelected = (_searchRadiusKm - radius).abs() < 0.1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchRadiusKm = radius;
                            });
                            _loadNearbyMosques();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${radius.toInt()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Re-search button - top left
          Positioned(
            top: 16,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _loadNearbyMosques,
              child: Icon(
                Icons.refresh,
                color: AppColors.primaryColor,
              ),
            ),
          ),

          // Mosque info panel - bottom
          if (_selectedMosque != null && !_isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: DraggableScrollableSheet(
                initialChildSize: 0.35,
                minChildSize: 0.25,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        verticalSpace(16),

                        // Mosque name
                        Text(
                          _selectedMosque!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        verticalSpace(12),

                        // Rating
                        if (_selectedMosque!.rating != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              horizontalSpace(8),
                              Text(
                                _selectedMosque!.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        verticalSpace(12),

                        // Distance
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            horizontalSpace(8),
                            Text(
                              '${_selectedMosque!.distanceKm.toStringAsFixed(2)} كم',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(12),

                        // Open/Closed status
                        if (_selectedMosque!.isOpen != null)
                          Row(
                            children: [
                              Icon(
                                _selectedMosque!.isOpen! ? Icons.check_circle : Icons.cancel,
                                color: _selectedMosque!.isOpen!
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              horizontalSpace(8),
                              Text(
                                _selectedMosque!.isOpen! ? 'مفتوح الآن' : 'مغلق الآن',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Tajawal',
                                  color: _selectedMosque!.isOpen!
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        verticalSpace(16),

                        // Address
                        if (_selectedMosque!.vicinity != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                horizontalSpace(8),
                                Expanded(
                                  child: Text(
                                    _selectedMosque!.vicinity!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        verticalSpace(12),

                        // Phone number
                        if (_selectedMosque!.phoneNumber != null)
                          GestureDetector(
                            onTap: () async {
                              final phoneUrl = 'tel:${_selectedMosque!.phoneNumber}';
                              if (await canLaunchUrl(Uri.parse(phoneUrl))) {
                                await launchUrl(Uri.parse(phoneUrl));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                  horizontalSpace(8),
                                  Expanded(
                                    child: Text(
                                      _selectedMosque!.phoneNumber!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Tajawal',
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        verticalSpace(16),

                        // Navigation button
                        ElevatedButton.icon(
                          onPressed: () => _launchMaps(
                            _selectedMosque!.latitude,
                            _selectedMosque!.longitude,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.directions),
                          label: const Text(
                            'الاتجاهات',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Tajawal',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
