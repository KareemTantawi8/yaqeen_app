import 'package:flutter/material.dart';

import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/utils/spacing.dart';

// ignore: must_be_immutable
class EventWidget extends StatelessWidget {
  EventWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    required this.date,
  });
  final String title;
  final String description;
  void Function()? onTap;
  final String date;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      collapsedIconColor: const Color(0xFF2B7669),
      iconColor: const Color(0xFF2B7669),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2B7669), // Primary color
          fontSize: 16,
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w500,
          height: 1.50,
          letterSpacing: 0.15,
        ),
        textAlign: TextAlign.right,
      ),
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: 0.80,
                child: Text(
                  date,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF1A2221), // Text color title
                    fontSize: 16,
                    fontFamily: FontFamilyHelper.fontFamily1,
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.10,
                  ),
                ),
              ),
              verticalSpace(8),
              Text(
                description,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2B7669),
                  fontFamily: FontFamilyHelper.fontFamily1,
                  height: 1.6,
                ),
              ),
              verticalSpace(16),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'معرفة المزيد',
                      style: TextStyle(
                        color: Color(0xFF2B7669),
                        fontSize: 14,
                        fontFamily: FontFamilyHelper.fontFamily1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.open_in_new_sharp,
                      color: Color(0xFF2B7669),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
