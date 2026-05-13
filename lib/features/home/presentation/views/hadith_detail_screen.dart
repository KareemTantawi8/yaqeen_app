import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_favorite_service.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';

class HadithDetailScreen extends StatefulWidget {
  final HadithModel hadith;

  const HadithDetailScreen({super.key, required this.hadith});

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await HadithFavoriteService.isFavorite(widget.hadith.refNo);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final newState = await HadithFavoriteService.toggleFavorite(widget.hadith);
    setState(() => _isFavorite = newState);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          newState ? 'تم الحفظ في المفضلة ❤️' : 'تم الحذف من المفضلة',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _share() {
    final text =
        '${widget.hadith.arabicText}\n\n— ${widget.hadith.bookName} ${widget.hadith.refNo}';
    Share.share(text);
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.hadith.arabicText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('تم نسخ الحديث',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: AppColors.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(sw),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHadithCard(sw),
                    verticalSpace(20),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(double sw) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _isFavorite
                    ? Colors.red.withOpacity(0.12)
                    : const Color(0xFFEAF9F4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : AppColors.primaryColor,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'تفاصيل الحديث',
            style: TextStyle(
              color: Color(0xFF2B7669),
              fontSize: 20,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
            ),
          ),
          horizontalSpace(8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF9F4),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_back, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(double sw) {
    final hadith = widget.hadith;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A5F54),
            Color(0xFF206B5E),
            Color(0xFF2B8A7A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(AppImages.triangleImage,
                    fit: BoxFit.cover, color: Colors.white),
              ),
            ),
            Positioned(top: -30, right: -30, child: _decor(120, 0.07)),
            Positioned(bottom: -20, left: -20, child: _decor(90, 0.05)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Book + ref row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hadith.refNo.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            hadith.refNo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Text(
                            hadith.bookName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          horizontalSpace(8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.menu_book_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Chapter
                  if (hadith.chapter.isNotEmpty) ...[
                    verticalSpace(12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hadith.chapter,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  verticalSpace(16),
                  Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                  verticalSpace(16),

                  // Arabic text
                  Text(
                    hadith.arabicText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Amiri Quran',
                      height: 2.0,
                    ),
                  ),

                  // English translation
                  if (hadith.englishText.isNotEmpty) ...[
                    verticalSpace(16),
                    Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                    verticalSpace(12),
                    Text(
                      hadith.englishText,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 13,
                        fontFamily: 'Tajawal',
                        height: 1.8,
                      ),
                    ),
                  ],

                  // Grade badge
                  if (hadith.grade.isNotEmpty) ...[
                    verticalSpace(16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.amber.withOpacity(0.5), width: 1),
                        ),
                        child: Text(
                          hadith.grade,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 13,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.copy_rounded,
            label: 'نسخ',
            onTap: _copy,
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: _actionButton(
            icon: Icons.share_rounded,
            label: 'مشاركة',
            onTap: _share,
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: _actionButton(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            label: _isFavorite ? 'محفوظ' : 'حفظ',
            onTap: _toggleFavorite,
            color: _isFavorite ? Colors.red : AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 24),
            verticalSpace(6),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 13,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decor(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}
