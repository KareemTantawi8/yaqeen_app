import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaqeen_app/core/services/service_locator.dart';
import 'package:yaqeen_app/yaqeen_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator for dependency injection
  await setupServiceLocator();

  final config = ClarityConfig(
      projectId: "scpt8xziyk",
      // TODO: Change LogLevel to Info or Warning for production builds
      logLevel: LogLevel.Verbose // Note: Use "LogLevel.Verbose" value while testing to debug initialization issues.
      );
  // try {
  //   final result = await InternetAddress.lookup('openrouter.ai');
  //   print(result);
  // } catch (e) {
  //   print('Failed DNS lookup: $e');
  // }
  runApp(
    ClarityWidget(
      app: ProviderScope(
        child: YaqeenApp(),
      ),
      clarityConfig: config,
    ),
  );
}
