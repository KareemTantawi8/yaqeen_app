import 'package:flutter/material.dart';

class TapIconWidget extends StatelessWidget {
  TapIconWidget({
    super.key,
    required this.image,
    required this.onTap,
  });
  void Function()? onTap;
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        image,
      ),
    );
  }
}
