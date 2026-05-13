import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_service.dart';
import '../ahadis_screen.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/utils/spacing.dart';

class HadithDailyCard extends StatefulWidget {
  const HadithDailyCard({super.key});

  @override
  State<HadithDailyCard> createState() => _HadithDailyCardState();
}

class _HadithDailyCardState extends State<HadithDailyCard> {
  HadithModel? _hadith;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final h = await HadithService.fetchHadithOfDay();
      if (mounted) setState(() { _hadith = h; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AhadisScreen()),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: sw * 0.01, vertical: sh * 0.005),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF1A3A35),
              Color(0xFF206B5E),
              Color(0xFF2B8A7A),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: Image.asset(
                    AppImages.triangleImage,
                    fit: BoxFit.cover,
                    color: Colors.white,
                  ),
                ),
              ),
              // Decorative circles
              Positioned(
                top: -sw * 0.08,
                left: -sw * 0.06,
                child: _circle(sw * 0.3, 0.07),
              ),
              Positioned(
                bottom: -sw * 0.06,
                right: -sw * 0.04,
                child: _circle(sw * 0.22, 0.05),
              ),

              Padding(
                padding: EdgeInsets.all(sw * 0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: sw * 0.13,
                      height: sw * 0.13,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: sw * 0.065,
                      ),
                    ),
                    horizontalSpace(sw * 0.04),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // "اقرأ المزيد" badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.03,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back_ios, color: Colors.white, size: sw * 0.03),
                                    horizontalSpace(3),
                                    Text(
                                      'اقرأ المزيد',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: sw * 0.03,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Title
                              Text(
                                'حديث اليوم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sw * 0.048,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(sh * 0.012),

                          // Hadith content
                          if (_isLoading)
                            Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white.withOpacity(0.7),
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else if (_hadith != null) ...[
                            Text(
                              _hadith!.arabicText,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: sw * 0.038,
                                fontFamily: 'Amiri Quran',
                                height: 1.9,
                              ),
                            ),
                            verticalSpace(sh * 0.008),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.025,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _hadith!.bookName,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: sw * 0.028,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ),
                            ),
                          ] else
                            Text(
                              'اضغط لقراءة الأحاديث الشريفة',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: sw * 0.038,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
