import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaqeen_app/core/services/location_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
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
  bool _isLoading = true;
  bool _hasError = false;
  double _searchRadiusKm = 5.0;
  double? _userLat;
  double? _userLng;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onRadiusChanged(double r) {
    setState(() => _searchRadiusKm = r);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _loadMosques);
  }

  Future<void> _initLocation() async {
    // Wait briefly so the home screen's GPS request can finish first.
    // Both screens start simultaneously (IndexedStack); concurrent location
    // requests cause "already running" errors and fallback to stale coords.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // getLocationWithFallback: tries GPS → saved → default (Riyadh)
    // By now the home screen's GPS call has completed and saved the real coords.
    final loc = await LocationService.getLocationWithFallback();
    if (!mounted) return;

    _userLat = loc['latitude'];
    _userLng = loc['longitude'];
    await _loadMosques();
  }

  Future<void> _loadMosques() async {
    if (_userLat == null || _userLng == null) return;
    if (mounted) setState(() { _isLoading = true; _hasError = false; });

    try {
      final mosques = await MosqueService.getNearbyMosques(
        latitude: _userLat!,
        longitude: _userLng!,
        radiusMeters: _searchRadiusKm * 1000,
      );
      if (mounted) setState(() { _mosques = mosques; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  Future<void> _openInMaps(MosqueModel mosque) async {
    final query = Uri.encodeComponent(mosque.name);
    final googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}&query_place_id=${mosque.placeId}';
    final appleUrl =
        'https://maps.apple.com/?q=$query&ll=${mosque.latitude},${mosque.longitude}';
    final uri = Uri.parse(googleUrl);
    final appleUri = Uri.parse(appleUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleUri)) {
      await launchUrl(appleUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              radiusKm: _searchRadiusKm,
              onRadiusChanged: _onRadiusChanged,
              onRefresh: _loadMosques,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_hasError) return _buildError();
    if (_mosques.isEmpty) return _buildEmpty();
    return _buildList();
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          SizedBox(height: 16),
          Text(
            'جاري البحث عن المساجد القريبة...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              color: Color(0xFF2D4A47),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Color(0xFFB0BEC5)),
            const SizedBox(height: 16),
            const Text(
              'تعذّر تحميل المساجد',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D4A47),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تحقق من اتصال الإنترنت وأذونات الموقع ثم أعد المحاولة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                color: Color(0xFF607D8B),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadMosques,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mosque_outlined, size: 64, color: Color(0xFFB0BEC5)),
          const SizedBox(height: 16),
          Text(
            'لا توجد مساجد ضمن ${_searchRadiusKm.toStringAsFixed(0)} كم',
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D4A47),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'حاول زيادة نطاق البحث',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              color: Color(0xFF607D8B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: _mosques.length,
      itemBuilder: (context, i) =>
          _MosqueCard(mosque: _mosques[i], onNavigate: _openInMaps),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final double radiusKm;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onRefresh;

  const _Header({
    required this.radiusKm,
    required this.onRadiusChanged,
    required this.onRefresh,
  });

  static const List<double> _options = [1.0, 3.0, 5.0, 10.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'تحديث',
              ),
              const Row(
                children: [
                  Text(
                    'المساجد القريبة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Radius chips
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'نطاق البحث: ',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              ..._options.map((r) {
                final selected = (radiusKm - r).abs() < 0.1;
                return GestureDetector(
                  onTap: () => onRadiusChanged(r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${r.toInt()} كم',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.primaryColor
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mosque card ───────────────────────────────────────────────────────────────

class _MosqueCard extends StatelessWidget {
  final MosqueModel mosque;
  final void Function(MosqueModel) onNavigate;

  const _MosqueCard({required this.mosque, required this.onNavigate});

  static const Color _ink = Color(0xFF0F2A26);
  static const Color _muted = Color(0xFF6B7F7B);
  static const Color _gold = Color(0xFFE0A93B);
  static const Color _surface = Color(0xFFF6FAF9);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onNavigate(mosque),
            splashColor: AppColors.primaryColor.withOpacity(0.05),
            highlightColor: AppColors.primaryColor.withOpacity(0.03),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    left: -30,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.06),
                            AppColors.primaryColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusChip(),
                            const Spacer(),
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    mosque.name,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                      height: 1.25,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (mosque.vicinity != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            mosque.vicinity!,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 12,
                                              color: _muted,
                                              height: 1.45,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.place_outlined,
                                          size: 13,
                                          color: _muted,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildIconBadge(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () => onNavigate(mosque),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.directions_rounded,
                                            size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'الاتجاهات',
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildMetaPill(
                                icon: Icons.near_me_rounded,
                                label: _distanceLabel(mosque.distanceKm),
                                iconColor: AppColors.primaryColor,
                              ),
                              if (mosque.rating != null) ...[
                                const SizedBox(width: 8),
                                _buildMetaPill(
                                  icon: Icons.star_rounded,
                                  label: mosque.rating!.toStringAsFixed(1),
                                  iconColor: _gold,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            Color(0xFF1A5F54),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: const Icon(
        Icons.mosque_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Widget _buildStatusChip() {
    if (mosque.isOpen == null) return const SizedBox.shrink();
    final open = mosque.isOpen!;
    final color = open ? const Color(0xFF1F9D5C) : const Color(0xFFD64545);
    final bg =
        open ? const Color(0xFFE9F8F0) : const Color(0xFFFDECEC);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            open ? 'مفتوح' : 'مغلق',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill({
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _ink,
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
