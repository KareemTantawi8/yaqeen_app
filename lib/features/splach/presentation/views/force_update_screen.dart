import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  static const String routeName = '/force-update';

  // Replace these with your actual store IDs before releasing.
  static const _androidPackageId = 'com.yaqeen.mobile';
  static const _iosAppId = ''; // e.g. '123456789'

  const ForceUpdateScreen({super.key});

  Future<void> _openStore() async {
    Uri uri;

    if (Platform.isIOS && _iosAppId.isNotEmpty) {
      uri = Uri.parse('https://apps.apple.com/app/id$_iosAppId');
    } else {
      uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_androidPackageId',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(1.05, 0.02),
              end: Alignment(0.00, 0.98),
              colors: [Color(0xFF206B5E), Color(0xFF329A88)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.system_update_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 32),
                const Text(
                  'يتطلب التحديث',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'يتوفر إصدار جديد من تطبيق يقين.\nيرجى التحديث للاستمرار في استخدام التطبيق.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.7,
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 220,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _openStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF206B5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'تحديث الآن',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
