import 'package:flutter/material.dart';
import '../../styles/colors/app_color.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const CustomLoadingWidget({
    super.key,
    this.message,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorSize = size! * 0.8;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: indicatorSize,
                  height: indicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.9),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                Icon(
                  Icons.mosque,
                  size: size! * 0.4,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
