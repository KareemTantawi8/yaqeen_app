import 'package:flutter/material.dart';

import '../../../../../core/styles/images/app_image.dart';

class RectangleWidget extends StatelessWidget {
  const RectangleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(1.05, 0.02),
          end: Alignment(0.00, 0.98),
          colors: [
            Color(0xFF206B5E),
            Color(0xFF329A88),
          ],
        ),
        image: DecorationImage(
          image: AssetImage(AppImages.triangleImage),
        ),
      ),
    );
  }
}
