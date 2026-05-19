import 'package:flutter/material.dart';
import '../../../../../core/extension/context_extension.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';

// ignore: must_be_immutable
class FeatureIconButton extends StatelessWidget {
  FeatureIconButton({
    super.key,
    required this.text,
    this.image,
    this.iconData,
    this.onTap,
  }) : assert(image != null || iconData != null,
            'Either image or iconData must be provided');
  void Function()? onTap;
  final String text;
  final String? image;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 53,
            width: 53,
            decoration: BoxDecoration(
              color: context.lightAccent,
              shape: BoxShape.circle,
            ),
            child: iconData != null
                ? Icon(iconData, color: AppColors.primaryColor, size: 26)
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(image!),
                  ),
          ),
        ),
        verticalSpace(5),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 14,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w500,
            height: 1.71,
            letterSpacing: 0.15,
          ),
        )
      ],
    );
  }
}
