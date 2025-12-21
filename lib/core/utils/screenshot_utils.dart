import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yaqeen_app/core/common/result.dart';
import 'package:yaqeen_app/core/constants/app_constants.dart';

class ScreenshotUtils {
  ScreenshotUtils._();

  /// Capture screenshot and save it
  static Future<Result<String>> captureAndSave(
    ScreenshotController controller,
  ) async {
    try {
      final image = await controller.capture();
      if (image == null) {
        return const Failure('Failed to capture screenshot');
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath =
          '${directory.path}/${AppConstants.screenshotPrefix}$timestamp${AppConstants.screenshotExtension}';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      return Success(imagePath);
    } catch (e) {
      return Failure('Error taking screenshot: $e');
    }
  }

  /// Share screenshot file
  static Future<Result<void>> shareScreenshot(String imagePath) async {
    try {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: AppConstants.screenshotShareText,
      );
      return const Success(null);
    } catch (e) {
      return Failure('Error sharing screenshot: $e');
    }
  }

  /// Capture, save and share screenshot in one operation
  static Future<Result<void>> captureSaveAndShare(
    ScreenshotController controller,
  ) async {
    final captureResult = await captureAndSave(controller);
    
    return captureResult.when(
      success: (imagePath) => shareScreenshot(imagePath),
      failure: (error) => Failure(error),
    );
  }
}

