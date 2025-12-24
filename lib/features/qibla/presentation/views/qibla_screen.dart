import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/qibla_service.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {
  Position? _currentPosition;
  double _qiblaDirection = 0.0;
  double _deviceHeading = 0.0;
  double _distanceToKaaba = 0.0;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<CompassEvent>? _compassSubscription;
  late AnimationController _needleController;
  late AnimationController _rippleController;
  late AnimationController _glowController;
  
  int _accuracy = 0;

  @override
  void initState() {
    super.initState();
    
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _initializeQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _needleController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _initializeQibla() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        throw Exception('تعذر الحصول على الموقع');
      }

      final qiblaDirection = QiblaService.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      final distance = QiblaService.calculateDistanceToKaaba(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _qiblaDirection = qiblaDirection;
          _distanceToKaaba = distance;
          _isLoading = false;
        });

        _startCompass();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _startCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null) {
        setState(() {
          _deviceHeading = event.heading!;
          _accuracy = event.accuracy?.toInt() ?? 0;
        });
      }
    });
  }

  double get _qiblaAngle {
    double angle = _qiblaDirection - _deviceHeading;
    if (angle > 180) angle -= 360;
    if (angle < -180) angle += 360;
    return angle;
  }

  bool get _isAligned => _qiblaAngle.abs() < 5;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isAligned ? Colors.green.withOpacity(0.1) : AppColors.primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState(sw, sh)
              : _errorMessage != null
                  ? _buildErrorState(sw, sh)
                  : _buildCompassView(sw, sh),
        ),
      ),
    );
  }

  Widget _buildLoadingState(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: sw * 0.2,
            height: sw * 0.2,
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 4,
            ),
          ),
          verticalSpace(sh * 0.03),
          Text(
            'جاري تحديد موقعك',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(double sw, double sh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: sw * 0.2, color: Colors.red),
            verticalSpace(sh * 0.03),
            Text(
              'فشل تحديد الموقع',
              style: TextStyle(
                fontSize: sw * 0.05,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            verticalSpace(sh * 0.02),
            Text(
              'تأكد من تفعيل خدمات الموقع',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.04,
                fontFamily: 'Tajawal',
                color: Colors.grey[700],
              ),
            ),
            verticalSpace(sh * 0.04),
            ElevatedButton(
              onPressed: _initializeQibla,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.08,
                  vertical: sh * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: sw * 0.04,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassView(double sw, double sh) {
    return Column(
      children: [
        _buildTopBar(sw, sh),
        _buildInfoCards(sw, sh),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildCompassRose(sw),
              _buildQiblaCompass(sw, sh),
              _buildQiblaArrow(sw, sh),
            ],
          ),
        ),
        _buildStatusIndicator(sw, sh),
        _buildCalibrationTip(sw, sh),
        verticalSpace(sh * 0.03),
      ],
    );
  }

  Widget _buildTopBar(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.04),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'اتجاه القبلة',
                style: TextStyle(
                  fontSize: sw * 0.05,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A2221),
                ),
              ),
              Text(
                'Qibla Direction',
                style: TextStyle(
                  fontSize: sw * 0.03,
                  fontFamily: 'Tajawal',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: AppColors.primaryColor),
              onPressed: _initializeQibla,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Row(
        children: [
          _buildInfoCard(
            'المسافة',
            QiblaService.formatDistance(_distanceToKaaba),
            Icons.straighten,
            sw,
            sh,
          ),
          horizontalSpace(sw * 0.03),
          _buildInfoCard(
            'الدقة',
            _accuracy > 0 ? '$_accuracy°' : '--',
            Icons.compass_calibration,
            sw,
            sh,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, double sw, double sh) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: sw * 0.06),
            verticalSpace(sh * 0.01),
            Text(
              value,
              style: TextStyle(
                fontSize: sw * 0.05,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w900,
                color: AppColors.primaryColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.03,
                fontFamily: 'Tajawal',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassRose(double sw) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Transform.rotate(
          angle: -_deviceHeading * math.pi / 180,
          child: SizedBox(
            width: sw * 0.8,
            height: sw * 0.8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                if (_isAligned)
                  Container(
                    width: sw * 0.7 * (1 + _rippleController.value * 0.2),
                    height: sw * 0.7 * (1 + _rippleController.value * 0.2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3 * (1 - _rippleController.value)),
                        width: 3,
                      ),
                    ),
                  ),
                // Direction markers
                ...List.generate(4, (index) {
                  final angle = index * 90.0;
                  final labels = ['N', 'E', 'S', 'W'];
                  final arabicLabels = ['ش', 'ق', 'ج', 'غ'];
                  
                  return Transform.rotate(
                    angle: angle * math.pi / 180,
                    child: Transform.translate(
                      offset: Offset(0, -sw * 0.35),
                      child: Transform.rotate(
                        angle: -angle * math.pi / 180,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              arabicLabels[index],
                              style: TextStyle(
                                fontSize: sw * 0.05,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: sw * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQiblaCompass(double sw, double sh) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: sw * 0.55,
          height: sw * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: _isAligned
                  ? [
                      Colors.green,
                      Colors.green.shade700,
                    ]
                  : [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (_isAligned ? Colors.green : AppColors.primaryColor)
                    .withOpacity(0.3 + (_glowController.value * 0.2)),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isAligned ? Icons.check_circle_outline : Icons.mosque,
                color: Colors.white,
                size: sw * 0.12,
              ),
              verticalSpace(sh * 0.01),
              Text(
                _isAligned ? 'صحيح' : 'الكعبة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sw * 0.04,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQiblaArrow(double sw, double sh) {
    return Transform.rotate(
      angle: _qiblaAngle * math.pi / 180,
      child: Icon(
        Icons.navigation,
        color: _isAligned ? Colors.green : Colors.red,
        size: sw * 0.15,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(double sw, double sh) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.08),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isAligned
              ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
              : [AppColors.primaryColor.withOpacity(0.15), AppColors.primaryColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: _isAligned
              ? Colors.green.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isAligned ? Icons.check_circle : Icons.explore,
            color: _isAligned ? Colors.green : AppColors.primaryColor,
            size: sw * 0.06,
          ),
          horizontalSpace(sw * 0.03),
          Flexible(
            child: Text(
              _isAligned ? 'اتجاه القبلة صحيح ✓' : 'حرك الجهاز للعثور على القبلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.038,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
                color: _isAligned ? Colors.green : AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationTip(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
      child: Container(
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(
            color: Colors.amber.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tips_and_updates,
              color: Colors.amber[700],
              size: sw * 0.05,
            ),
            horizontalSpace(sw * 0.03),
            Expanded(
              child: Text(
                'نصيحة: حرك جهازك بحركة رقم 8 لمعايرة البوصلة',
                style: TextStyle(
                  fontSize: sw * 0.032,
                  fontFamily: 'Tajawal',
                  color: Colors.amber[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
