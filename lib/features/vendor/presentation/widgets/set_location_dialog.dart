import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../data/repo/vendor_location_service.dart';

/// Dialog to set vendor's current GPS location and send to API
class SetLocationDialog extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const SetLocationDialog({
    super.key,
    this.onSuccess,
    this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SetLocationDialog(
        onSuccess: onSuccess,
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  State<SetLocationDialog> createState() => _SetLocationDialogState();
}

class _SetLocationDialogState extends State<SetLocationDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _setCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Get current GPS location
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        final hasPermission = await LocationService.requestLocationPermission();
        if (!hasPermission && mounted) {
          final useLocation = await LocationService.showLocationPermissionDialog(context);
          if (useLocation == true) {
            await LocationService.openLocationSettings();
          }
        }
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعذر الحصول على الموقع. يرجى التأكد من تفعيل خدمات الموقع والإذن.';
        });
        return;
      }

      // Call API to update vendor location
      final response = await VendorLocationService.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      if (response.success) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isLoading = false;
          _successMessage = response.message;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop(true);
          widget.onSuccess?.call();
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      debugPrint('SetLocationDialog error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'حدث خطأ أثناء تحديث الموقع. تأكد من الاتصال بالإنترنت وحاول مرة أخرى.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 36,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'تحديد موقع المتجر',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.titleColor,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'انقر على الزر أدناه لتحديد موقعك الحالي وإرساله إلى الخادم. سيتم استخدام إحداثيات GPS الدقيقة لموقع متجرك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                height: 1.6,
                color: AppColors.thinText,
              ),
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          color: AppColors.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_successMessage != null)
              Icon(Icons.check_circle, color: Colors.green, size: 48),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop(false);
                            widget.onCancel?.call();
                          },
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: AppColors.thinText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _setCurrentLocation,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.my_location_rounded, size: 20),
                    label: Text(
                      _isLoading ? 'جاري التحديث...' : 'تحديد الموقع الحالي',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
