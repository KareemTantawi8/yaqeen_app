import 'package:flutter/material.dart';

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

      _notifier.loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final readingProgress = _notifier.progress;
    final hasProgress = readingProgress != null;
    final percent = hasProgress ? readingProgress.progressPercentage / 100 : 0.0;

    return GestureDetector(
      onTap: _navigateToSurah,
      child: Container(
        height: 132,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A5F54),
              AppColors.primaryColor,
              Color(0xFF2A8A78),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.32),
              blurRadius: 22,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.07,
                  child: Image.asset(
                    AppImages.triangleImage,
                    fit: BoxFit.cover,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          if (hasProgress)
                            SizedBox(
                              width: 78,
                              height: 78,
                              child: CircularProgressIndicator(
                                value: percent,
                                strokeWidth: 4.5,
                                backgroundColor: Colors.white.withOpacity(0.18),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Colors.white.withOpacity(0.78),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.primaryColor,
                              size: 28,
                            ),
                          ),
                          if (hasProgress)
                            Positioned(
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0A93B),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${readingProgress.progressPercentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Tajawal',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                hasProgress ? 'تابع القراءة' : 'القرآن الكريم',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.82),
                                  fontSize: 12,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0A93B),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE0A93B)
                                          .withOpacity(0.7),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasProgress
                                ? readingProgress.surahEnglishName
                                : 'ابدأ رحلة القراءة',
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasProgress
                                      ? 'آية ${readingProgress.ayahNumber} / ${readingProgress.totalAyahs}'
                                      : 'اضغط للبدء',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Tajawal',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primaryColor,
                        size: 18,
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
}
