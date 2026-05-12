import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/styles/colors/app_color.dart';
import 'set_location_dialog.dart';

/// A styled card with map-like placeholder and "Set Address" button for vendor dashboard.
/// When tapped, shows a dialog to set current GPS location and sends it via API.
class VendorLocationCard extends StatelessWidget {
  final String? currentAddress;
  final VoidCallback? onLocationUpdated;

  const VendorLocationCard({
    super.key,
    this.currentAddress,
    this.onLocationUpdated,
  });

  void _onSetAddressTap(BuildContext context) {
    HapticFeedback.lightImpact();
    SetLocationDialog.show(
      context,
      onSuccess: onLocationUpdated,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map-like placeholder
            _MapPlaceholder(currentAddress: currentAddress),
            // Set Address button
            Material(
              color: AppColors.primaryColor,
              child: InkWell(
                onTap: () => _onSetAddressTap(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_location_alt_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'تحديد العنوان',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Map-style placeholder with grid pattern and location pin
class _MapPlaceholder extends StatelessWidget {
  final String? currentAddress;

  const _MapPlaceholder({this.currentAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8F5F3),
            const Color(0xFFD4EDE8),
            AppColors.primaryColor.withOpacity(0.15),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Grid pattern (map-like)
          CustomPaint(
            size: const Size(double.infinity, 180),
            painter: _GridPatternPainter(),
          ),
          // Center pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 32,
                    color: AppColors.primaryColor,
                  ),
                ),
                if (currentAddress != null && currentAddress!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      currentAddress!,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: AppColors.titleColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'لم يتم تحديد الموقع بعد',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: AppColors.thinText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Corner decoration
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_rounded, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'موقع المتجر',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a subtle grid pattern for map-like appearance
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryColor.withOpacity(0.06)
      ..strokeWidth = 1;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
