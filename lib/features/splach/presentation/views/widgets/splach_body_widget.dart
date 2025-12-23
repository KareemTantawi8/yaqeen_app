import 'package:flutter/material.dart';

import '../../../../../core/styles/images/app_image.dart';
import '../../../../home/presentation/views/bottom_nav_bar.dart';

class SplashScreenBody extends StatefulWidget {
  const SplashScreenBody({Key? key}) : super(key: key);

  @override
  State<SplashScreenBody> createState() => _SplashScreenBodyState();
}

class _SplashScreenBodyState extends State<SplashScreenBody>
    with SingleTickerProviderStateMixin {
  late AnimationController controler;
  late Animation<Offset> animate;

  @override
  void initState() {
    super.initState();
    controler =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animate = Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero)
        .animate(controler);
    controler.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavBar(),
        ),
      );
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controler.dispose();
  }

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
          image: AssetImage('assets/images/triangle.png'),
        ),
      ),
      child: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              AppImages.mosqueImage,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SizedBox(
              width: 106.60,
              height: 115.67,
              child: Image.asset(
                AppImages.yaqeenImage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
