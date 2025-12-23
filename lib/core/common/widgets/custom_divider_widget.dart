import 'package:flutter/material.dart';

import '../../styles/colors/app_color.dart';

class CustomDividerWidget extends StatelessWidget {
  const CustomDividerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.primaryColor.withOpacity(0.2),
    );
  }
}
