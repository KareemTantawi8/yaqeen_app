import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaqeen_app/core/services/location_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/features/mosque/data/models/mosque_model.dart';
import 'package:yaqeen_app/features/mosque/data/services/mosque_service.dart';

class MosqueMapScreen extends StatefulWidget {
  static const String routeName = '/mosque_map';
  const MosqueMapScreen({super.key});

  @override
  State<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends State<MosqueMapScreen> {
  // Completer guards against calling the controller before onMapCreated fires
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? _userLocation;
  Set<Marker> _markers = {};
  MosqueModel? _selectedMosque;
  bool _isLoading = true;
  bool _hasError = false;
  double _searchRadiusKm = 5.0;

  static const List<double> _radiusOptions = [1.0, 3.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final saved = await LocationService.getSavedLocation();
    final immediate = saved ?? {
      'latitude': LocationService.defaultLatitude,
      'longitude': LocationService.defaultLongitude,
    };
    _userLocation = LatLng(
      immediate['latitude'] as double,
      immediate['longitude'] as double,
    );
    await _loadMosques();

    // GPS refresh
    try {
      final pos = await LocationService.getCurrentLocation()
          .timeout(const Duration(seconds: 12));
      if (pos == null || !mounted) return;
      final newLoc = LatLng(pos.latitude, pos.longitude);
      final latDiff = (newLoc.latitude - _userLocation!.latitude).abs();
      final lngDiff = (newLoc.longitude - _userLocation!.longitude).abs();
      if (latDiff < 0.005 && lngDiff < 0.005) return;
      _userLocation = newLoc;
      final mapCtrl = await _controller.future;
      await mapCtrl.animateCamera(CameraUpdate.newLatLng(_userLocation!));
      await _loadMosques();
    } catch (_) {}
  }

  Future<void> _loadMosques() async {
    if (_userLocation == null) return;
    if (mounted) {
      setState(() { _isLoading = true; _hasError = false; _selectedMosque = null; });
    }

    try {
      final mosques = await MosqueService.getNearbyMosques(
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        radiusMeters: _searchRadiusKm * 1000,
      );

      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'موقعك الحالي'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        for (final m in mosques)
          Marker(
            markerId: MarkerId(m.placeId),
            position: LatLng(m.latitude, m.longitude),
            infoWindow: InfoWindow(
              title: m.name,
              snippet: _distanceLabel(m.distanceKm),
            ),
            onTap: () => setState(() => _selectedMosque = m),
          ),
      };

      if (mounted) setState(() { _markers = markers; _isLoading = false; });

      // Animate to user location after markers are set
      final mapCtrl = await _controller.future;
      await mapCtrl.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation!, zoom: 14),
      ));
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  Future<void> _launchDirections(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller.future.then((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (c) => _controller.complete(c),
            initialCameraPosition: CameraPosition(
              target: _userLocation ?? const LatLng(21.4225, 39.8262),
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    // Refresh
                    _MapButton(
                      icon: Icons.refresh_rounded,
                      onTap: _loadMosques,
                    ),
                    const Spacer(),
                    // Radius chips
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _radiusOptions.map((r) {
                          final sel = (_searchRadiusKm - r).abs() < 0.1;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _searchRadiusKm = r);
                              _loadMosques();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${r.toInt()}كم',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: sel
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
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryColor),
                      SizedBox(height: 12),
                      Text(
                        'جاري تحميل المساجد...',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          color: Color(0xFF2D4A47),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Error overlay
          if (_hasError && !_isLoading)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'تعذّر تحميل المساجد',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadMosques,
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryColor),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom mosque info panel
          if (_selectedMosque != null && !_isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MosqueInfoPanel(
                mosque: _selectedMosque!,
                onClose: () => setState(() => _selectedMosque = null),
                onNavigate: (m) => _launchDirections(m.latitude, m.longitude),
              ),
            ),
        ],
      ),
    );
  }

  String _distanceLabel(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} م';
    return '${km.toStringAsFixed(1)} كم';
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 20),
      ),
    );
  }
}

class _MosqueInfoPanel extends StatelessWidget {
  final MosqueModel mosque;
  final VoidCallback onClose;
  final void Function(MosqueModel) onNavigate;

  const _MosqueInfoPanel({
    required this.mosque,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle + close
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                padding: EdgeInsets.zero,
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mosque.name,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2221),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (mosque.isOpen != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: mosque.isOpen!
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mosque.isOpen! ? 'مفتوح' : 'مغلق',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: mosque.isOpen!
                          ? const Color(0xFF388E3C)
                          : const Color(0xFFD32F2F),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (mosque.rating != null) ...[
                Text(
                  mosque.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D4A47),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFC107), size: 16),
                const SizedBox(width: 10),
              ],
              Text(
                _distanceLabel(mosque.distanceKm),
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.near_me_rounded,
                  size: 14, color: AppColors.primaryColor),
            ],
          ),
          if (mosque.vicinity != null) ...[
            const SizedBox(height: 6),
            Text(
              mosque.vicinity!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Color(0xFF607D8B),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onNavigate(mosque),
              icon: const Icon(Icons.directions_rounded),
              label: const Text(
                'الاتجاهات',
                style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _distanceLabel(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} م';
    return '${km.toStringAsFixed(1)} كم';
  }
}
