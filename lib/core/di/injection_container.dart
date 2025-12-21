import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

final sl = GetIt.instance;

bool _isInitialized = false;

/// Initialize dependency injection container
Future<void> init() async {
  if (_isInitialized) {
    return;
  }

  // External
  final appDocumentsDir = await getApplicationDocumentsDirectory();
  
  if (!sl.isRegistered<Directory>()) {
    sl.registerLazySingleton<Directory>(() => appDocumentsDir);
  }
  
  if (!sl.isRegistered<ScreenshotController>()) {
    sl.registerLazySingleton(() => ScreenshotController());
  }
  
  if (!sl.isRegistered<Share>()) {
    sl.registerLazySingleton(() => Share);
  }

  // Features
  // Register feature-specific dependencies here

  _isInitialized = true;
}

