import 'package:flutter/material.dart';

import '../../../../../core/services/quran_reading_service.dart';
import '../../../../../core/services/reading_progress_notifier.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../data/models/surah_model.dart';
import '../surah_detail_screen.dart';

class RecentQuranRead extends StatefulWidget {
  const RecentQuranRead({super.key});

  @override
  State<RecentQuranRead> createState() => _RecentQuranReadState();
}

class _RecentQuranReadState extends State<RecentQuranRead> {
  final ReadingProgressNotifier _notifier = ReadingProgressNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onProgressChanged);
    _notifier.loadProgress();
  }

  @override
  void dispose() {
    _notifier.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToSurah() async {
    final readingProgress = _notifier.progress;
    
    if (readingProgress != null) {
      final surah = Surah(
        number: readingProgress.surahNumber,
        name: readingProgress.surahName,
        englishName: readingProgress.surahEnglishName,
        englishNameTranslation: '',
        numberOfAyahs: readingProgress.totalAyahs,
        revelationType: '',
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurahDetailScreen(
            surah: surah,
            initialAyahNumber: readingProgress.ayahNumber,
          ),
        ),
      );
      
      // Reload progress when returning
      _notifier.loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final readingProgress = _notifier.progress;

    return Container(
      height: screenHeight * 0.24,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
        vertical: screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.85),
            const Color(0xFF1a5f54),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Animated background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  AppImages.triangleImage,
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Glassmorphic overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                children: [
                  // Left side - Text content
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header with icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    readingProgress != null ? 'القراءة مؤخراً' : 'ابدأ القراءة',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: screenWidth * 0.032,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (readingProgress != null)
                                    Text(
                                      '${readingProgress.progressPercentage.toStringAsFixed(0)}% مكتمل',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: screenWidth * 0.028,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Surah name and ayah
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              readingProgress?.surahEnglishName ?? 'القرآن الكريم',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.065,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.025,
                                vertical: screenHeight * 0.006,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                readingProgress != null
                                    ? 'آية ${readingProgress.ayahNumber} من ${readingProgress.totalAyahs}'
                                    : 'اختر سورة للبدء',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.032,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Progress bar (if reading)
                        if (readingProgress != null)
                          Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: readingProgress.progressPercentage / 100,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        // Action button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _navigateToSurah,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.015,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    readingProgress != null ? 'استمرار القراءة' : 'ابدأ الآن',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: screenWidth * 0.038,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.primaryColor,
                                    size: screenWidth * 0.05,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side - Decorative illustration
                  Expanded(
                    flex: 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: screenWidth * 0.35,
                          height: screenWidth * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Quran image
                        Transform.rotate(
                          angle: 0.1,
                          child: Image.asset(
                            AppImages.mosafImage,
                            height: screenHeight * 0.22,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ]),
                  ),
                ),
    ),

          ],
        ),
      ),
             );
  }
}
