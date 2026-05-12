import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaqeen_app/core/services/location_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/mosque/data/models/mosque_model.dart';
import 'package:yaqeen_app/features/mosque/data/services/mosque_service.dart';

class MosqueListScreen extends StatefulWidget {
  static const String routeName = '/mosque_list';

  const MosqueListScreen({super.key});

  @override
  State<MosqueListScreen> createState() => _MosqueListScreenState();
}

class _MosqueListScreenState extends State<MosqueListScreen> {
  List<MosqueModel> _mosques = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  double _searchRadiusKm = 5.0;

  final List<double> _radiusOptions = [1.0, 3.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _loadNearbyMosques();
  }

  Future<void> _loadNearbyMosques() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      final location = await LocationService.getLocationWithFallback();
      final userLat = location['latitude'] as double;
      final userLng = location['longitude'] as double;

      debugPrint(
          'Loading mosques near: $userLat, $userLng with radius: ${_searchRadiusKm}km');

      final mosques = await MosqueService.getNearbyMosques(
        latitude: userLat,
        longitude: userLng,
        radiusMeters: _searchRadiusKm * 1000,
      );

      if (mounted) {
        setState(() {
          _mosques = mosques;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load nearby mosques: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _launchMaps(double latitude, double longitude, String name) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
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
      body: Column(
        children: [
          // Radius selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نطاق البحث: ${_searchRadiusKm.toStringAsFixed(1)} كم',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                  ),
                ),
                verticalSpace(12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _radiusOptions.map((radius) {
                      final isSelected = (_searchRadiusKm - radius).abs() < 0.1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchRadiusKm = radius;
                            });
                            _loadNearbyMosques();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${radius.toInt()} كم',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontFamily: 'Tajawal',
                              ),
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
          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                    ? _buildErrorState()
                    : _mosques.isEmpty
                        ? _buildEmptyState()
                        : _buildMosquesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: _loadNearbyMosques,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
          verticalSpace(16),
          const Text(
            'جاري تحميل المساجد القريبة...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            verticalSpace(16),
            Text(
              'خطأ في تحميل المساجد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontFamily: 'Tajawal',
              ),
            ),
            verticalSpace(8),
            Text(
              _errorMessage ?? 'حدث خطأ غير معروف',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace(24),
            ElevatedButton(
              onPressed: _loadNearbyMosques,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          verticalSpace(16),
          Text(
            'لا توجد مساجد قريبة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'Tajawal',
            ),
          ),
          verticalSpace(8),
          Text(
            'حاول زيادة نطاق البحث',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosquesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _mosques.length,
      itemBuilder: (context, index) {
        final mosque = _mosques[index];
        return _buildMosqueCard(mosque);
      },
    );
  }

  Widget _buildMosqueCard(MosqueModel mosque) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _launchMaps(mosque.latitude, mosque.longitude, mosque.name),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mosque name and distance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalSpace(4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                            horizontalSpace(4),
                            Text(
                              '${mosque.distanceKm.toStringAsFixed(2)} كم',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Rating
                  if (mosque.rating != null)
                    Column(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        verticalSpace(4),
                        Text(
                          mosque.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              verticalSpace(12),
              // Address
              if (mosque.vicinity != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    horizontalSpace(8),
                    Expanded(
                      child: Text(
                        mosque.vicinity!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              verticalSpace(12),
              // Status and Navigation button
              Row(
                children: [
                  if (mosque.isOpen != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: mosque.isOpen! ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          mosque.isOpen! ? '🟢 مفتوح الآن' : '🔴 مغلق الآن',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mosque.isOpen! ? Colors.green[700] : Colors.red[700],
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                  horizontalSpace(8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _launchMaps(mosque.latitude, mosque.longitude, mosque.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text(
                      'الاتجاهات',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
