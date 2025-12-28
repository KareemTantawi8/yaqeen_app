import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/styles/fonts/font_styles.dart';
import 'package:yaqeen_app/core/styles/images/app_image.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/qibla/presentation/views/qibla_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/adhan_full_screen.dart';
import 'package:yaqeen_app/features/home/presentation/views/mespha_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: TextStyles.font18PrimaryText.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpace(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                icon: AppImages.qeplaIcon,
                label: 'القبلة',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QiblaScreen(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: AppImages.azanIcon,
                label: 'الأذان',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdhanFullScreen(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: AppImages.mesphaIcon,
                label: 'المسبحة',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MesphaScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                icon,
                width: 32,
                height: 32,
                color: color,
              ),
            ),
            verticalSpace(8),
            Text(
              label,
              style: TextStyles.font14PrimaryText.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

