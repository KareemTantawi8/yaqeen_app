import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class AppImages {
  static const String mosqueImage = "assets/images/mosque_image.png";
  static const String yaqeenImage = "assets/images/Yaqeen.png";
  static const String azkarIcon = "assets/icons/azkar_icon.png";
  static const String eventIcon = "assets/icons/event_icon.png";
  static const String prayerIcons = "assets/icons/prayer_icon.png";
  static const String settingIcons = "assets/images/settings.png";
  static const String triangleImage = "assets/images/triangle.png";
  static const String cloudeImage = "assets/images/cloud_image.png";
  static const String cloudSunnyImage = "assets/images/cloud_sunny_widget.png";
  static const String moonImage = "assets/images/moon_icon.png";
  static const String sunImage = "assets/images/sun_icon.png";
  static const String sunnyImage = "assets/images/sun2_icon.png";
  static const String cloudefog = "assets/images/cloud-fog.png";
  static const String middleContainer = "assets/images/Frame 72.png";
  static const String azanIcon = "assets/icons/azan_icon.png";
  static const String mesphaIcon = "assets/icons/mespha_icon.png";
  static const String qeplaIcon = "assets/icons/qepla_icon.png";
  static const String dialogImage = "assets/images/dialog_image.png";
  static const String zikirmatikImage = "assets/images/zikirmatik_image.png";
  static const String shape2Image = "assets/images/shape2.png";
  static const String askarHelperImage = "assets/images/askar_helper_image.png";
  static const String bestIcon = "assets/icons/best_icon.png";
  static const String bookIcon = "assets/icons/book_icon.png";
  static const String saveIcon = "assets/icons/save_icon.png";
  static const String copyIcon = "assets/icons/copy_icon.png";
  static const String shareIcon = "assets/icons/share_icon.png";
  static const String radioIcon = "assets/icons/radio_icon.png";
  static const String hadisBannerWidget = "assets/images/hadis_banner_image.png";
}

/// Decodes [AppImages.triangleImage] at the on-screen size to avoid decoding
/// the full asset when only a smaller region is painted.
ImageProvider triangleDecorationImage(
  BuildContext context, {
  double? width,
  double? height,
}) {
  final screen = MediaQuery.sizeOf(context);
  final dpr = MediaQuery.devicePixelRatioOf(context);
  final logicalW = width ?? screen.width;
  final logicalH = height ?? screen.height;

  return ResizeImage(
    AssetImage(AppImages.triangleImage),
    width: (logicalW * dpr).round(),
    height: (logicalH * dpr).round(),
  );
}

/// Decorative triangle texture sized to its parent (or the screen when unbounded).
class TriangleTexture extends StatelessWidget {
  const TriangleTexture({
    super.key,
    this.fit = BoxFit.cover,
    this.color,
    this.opacity = 1.0,
  });

  final BoxFit fit;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = MediaQuery.sizeOf(context);
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final logicalW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screen.width;
        final logicalH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : screen.height;

        final image = Image.asset(
          AppImages.triangleImage,
          fit: fit,
          color: color,
          width: logicalW,
          height: logicalH,
          cacheWidth: (logicalW * dpr).round(),
          cacheHeight: (logicalH * dpr).round(),
        );

        if (opacity < 1.0) {
          return Opacity(opacity: opacity, child: image);
        }
        return image;
      },
    );
  }
}
