import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/splach/presentation/views/widgets/splach_body_widget.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = '/';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // backgroundColor: Color(0xff00A9FF),
      body: SplashScreenBody(),
    );
  }
}
