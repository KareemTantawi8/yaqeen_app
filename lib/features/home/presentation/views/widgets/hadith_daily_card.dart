import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_service.dart';
import '../ahadis_screen.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/images/app_image.dart';

class HadithDailyCard extends StatefulWidget {
  const HadithDailyCard({super.key});

  @override
  State<HadithDailyCard> createState() => _HadithDailyCardState();
}

class _HadithDailyCardState extends State<HadithDailyCard> {
  HadithModel? _hadith;
  bool _isLoading = true;

  static const Color _cream = Color(0xFFFBF6EC);
  static const Color _creamDeep = Color(0xFFF3EAD3);
  static const Color _gold = Color(0xFFC79435);
  static const Color _ink = Color(0xFF1F3D38);

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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AhadisScreen()),
      ),
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_cream, _creamDeep],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _gold.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: -3,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    AppImages.triangleImage,
                    fit: BoxFit.cover,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),

              Positioned(
                top: -28,
                left: -28,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _gold.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -22,
                right: -22,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.today_rounded,
                                  color: Colors.white, size: 11),
                              SizedBox(width: 3),
                              Text(
                                'اليوم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Tajawal',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryColor,
                                Color(0xFF1A5F54),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primaryColor.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'حديث اليوم',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_isLoading)
                          SizedBox(
                            height: 14,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    color: _gold,
                                    strokeWidth: 1.6,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'جاري التحميل...',
                                  style: TextStyle(
                                    color: _ink.withOpacity(0.55),
                                    fontFamily: 'Tajawal',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_hadith != null)
                          Text(
                            _hadith!.arabicText,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _ink.withOpacity(0.72),
                              fontSize: 11.5,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          )
                        else
                          Text(
                            'اضغط لقراءة الأحاديث الشريفة',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: _ink.withOpacity(0.6),
                              fontFamily: 'Tajawal',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'اقرأ المزيد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
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
}
