import 'package:flutter/material.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      // case Routes.splachScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => const SplashScreen(),
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: SizedBox.shrink(),
          ),
        );
    }
  }
}
