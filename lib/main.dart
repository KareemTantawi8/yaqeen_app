import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaqeen_app/core/constants/app_constants.dart';
import 'package:yaqeen_app/core/di/injection_container.dart';
import 'package:yaqeen_app/core/style/app_theme.dart';
import 'package:yaqeen_app/features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const YaqeenApp());
}

class YaqeenApp extends StatelessWidget {
  const YaqeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashView(),
    );
  }
}
