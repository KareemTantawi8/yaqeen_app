import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/presentation/views/widgets/tap_icon_widget.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class RelatedHadisWidget extends StatelessWidget {
  RelatedHadisWidget({
    super.key,
    required this.arHadis,
    required this.enHadis,
    required this.num,
    required this.copyTap,
    required this.shareTap,
    required this.saveTap,
  });
  void Function()? copyTap;
  void Function()? shareTap;
  void Function()? saveTap;
  final String num;
  final String arHadis;
  final String enHadis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 370,
      width: double.infinity,
      child: Column(
        children: [
          Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  TapIconWidget(
                    image: AppImages.copyIcon,
                    onTap: copyTap,
                  ),
                  horizontalSpace(15),
                  TapIconWidget(
                    image: AppImages.shareIcon,
                    onTap: shareTap,
                  ),
                  horizontalSpace(15),
                  TapIconWidget(
                    image: AppImages.saveIcon,
                    onTap: saveTap,
                  ),
                  const Spacer(),
                  Container(
                    height: 25,
                    width: 25,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        num,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          verticalSpace(8),
          SizedBox(
            width: 327,
            child: Text(
              arHadis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF1A2221) /* Text_Color-TItle */,
                fontSize: 18,
                fontFamily: 'Amiri Quran',
                fontWeight: FontWeight.w400,
                height: 1.60,
              ),
            ),
          ),
          verticalSpace(14),
          SizedBox(
            width: 327,
            child: Text(
              enHadis,
              style: const TextStyle(
                color: Color(0xFF6F8F87) /* Text_Color-Sutitle */,
                fontSize: 12,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
