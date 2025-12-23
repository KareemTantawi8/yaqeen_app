import 'package:flutter/material.dart';

import '../colors/app_color.dart';
import 'font_family_helper.dart';

class TextStyles {
  static TextStyle font14WhiteText = const TextStyle(
    color: AppColors.boldText /* bgCOlor */,
    fontSize: 14,
    fontFamily: FontFamilyHelper.fontFamily1,
    fontWeight: FontWeight.w700,
    height: 1.43,
    letterSpacing: 0.10,
  );
  static TextStyle font24WhiteText = const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontFamily: FontFamilyHelper.fontFamily1,
    fontWeight: FontWeight.w700,
  );
  static TextStyle font48WhiteText = const TextStyle(
    color: AppColors.boldText /* bgCOlor */,
    fontSize: 48,
    fontFamily: FontFamilyHelper.fontFamily1,
    fontWeight: FontWeight.w700,
    height: 1,
  );
  static TextStyle font12WhiteText = const TextStyle(
    color: AppColors.boldText /* bgCOlor */,
    fontSize: 12,
    fontFamily: FontFamilyHelper.fontFamily1,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.10,
  );
  static TextStyle font20PrimaryText = const TextStyle(
    color: const Color(0xFF2B7669) /* Primarycolor */,
    fontSize: 20,
    fontFamily: FontFamilyHelper.fontFamily2,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.10,
  );
}
