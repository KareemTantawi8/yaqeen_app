import 'package:flutter/material.dart';

import '../../../../core/styles/colors/app_color.dart';
import '../widgets/vendor_location_card.dart';

/// Vendor dashboard screen with location setting
class VendorDashboardScreen extends StatefulWidget {
  static const String routeName = '/VendorDashboardScreen';

  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  String? _currentAddress;

  void _onLocationUpdated() {
    setState(() {
      _currentAddress = 'تم تحديث الموقع بنجاح';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'لوحة تحكم البائع',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            color: AppColors.titleColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location card
            VendorLocationCard(
              currentAddress: _currentAddress,
              onLocationUpdated: _onLocationUpdated,
            ),
          ],
        ),
      ),
    );
  }
}
