import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import 'package:yaqeen_app/features/home/data/models/hadeethenc_models.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_favorite_service.dart';
import 'package:yaqeen_app/features/home/data/repo/hadeethenc_service.dart';
import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';

class HadeethEncDetailScreen extends StatefulWidget {
  final String hadithId;
  final String hadithTitle;
  final Color accentColor;

  const HadeethEncDetailScreen({
    super.key,
    required this.hadithId,
    required this.hadithTitle,
    required this.accentColor,
  });

  @override
  State<HadeethEncDetailScreen> createState() =>
      _HadeethEncDetailScreenState();
}

class _HadeethEncDetailScreenState extends State<HadeethEncDetailScreen> {
  HadeethEncHadith? _hadith;
  bool _isLoading = true;
  String? _error;
  bool _explanationExpanded = false;
  bool _hintsExpanded = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final h = await HadeethEncService.fetchHadithDetail(widget.hadithId);
      final fav = await HadithFavoriteService.isFavorite(widget.hadithId);
      if (mounted) {
        setState(() {
          _hadith = h;
          _isFavorite = fav;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_hadith == null) return;
    final model = HadithModel(
      bookName: _hadith!.attribution.isNotEmpty
          ? _hadith!.attribution
          : 'HadeethEnc',
      bookKey: 'hadeethenc',
      chapter: _hadith!.title,
      arabicText: _hadith!.matn,
      englishText: '',
      grade: _hadith!.grade,
      refNo: widget.hadithId,
      tafsir: _hadith!.explanation,
    );
    final next = await HadithFavoriteService.toggleFavorite(model);
    if (mounted) {
      setState(() => _isFavorite = next);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          next ? 'تم الحفظ في المفضلة ❤️' : 'تم الحذف من المفضلة',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _share() {
    if (_hadith == null) return;
    Share.share('${_hadith!.matn}\n\n— ${_hadith!.attribution}');
  }

  void _copy() {
    if (_hadith == null) return;
    Clipboard.setData(ClipboardData(text: _hadith!.matn));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('تم نسخ الحديث',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: AppColors.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
                    : context.lightAccent,
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
          Flexible(
            child: Text(
              widget.hadithTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.brandText,
                fontSize: 17,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          horizontalSpace(8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: context.lightAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_sharp,
                  color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 60, color: AppColors.primaryColor),
              verticalSpace(12),
              Text(
                'تعذّر تحميل الحديث',
                style: TextStyle(
                  color: context.highText,
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              verticalSpace(20),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final h = _hadith!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHadithCard(h),
          if (h.explanation.isNotEmpty) ...[
            verticalSpace(14),
            _buildCollapsibleCard(
              title: 'شرح الحديث',
              icon: Icons.lightbulb_outline_rounded,
              body: h.explanation,
              expanded: _explanationExpanded,
              onToggle: () => setState(
                  () => _explanationExpanded = !_explanationExpanded),
            ),
          ],
          if (h.hints.isNotEmpty) ...[
            verticalSpace(12),
            _buildHintsCard(h.hints),
          ],
          verticalSpace(20),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHadithCard(HadeethEncHadith h) {
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
            const Positioned.fill(
              child: TriangleTexture(opacity: 0.05, color: Colors.white),
            ),
            Positioned(
                top: -30, right: -30, child: _decor(120, 0.07)),
            Positioned(
                bottom: -20, left: -20, child: _decor(90, 0.05)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attribution / source
                  if (h.attribution.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            h.attribution,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                            ),
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

                  verticalSpace(16),
                  Divider(
                      color: Colors.white.withOpacity(0.3), thickness: 1),
                  verticalSpace(16),

                  // Matn
                  Text(
                    h.matn,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Amiri Quran',
                      height: 2.0,
                    ),
                  ),

                  // Grade
                  if (h.grade.isNotEmpty) ...[
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
                              color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: Text(
                          h.grade,
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

  Widget _buildCollapsibleCard({
    required String title,
    required IconData icon,
    required String body,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.primaryColor, size: 22),
                  ),
                  horizontalSpace(8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 15,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  horizontalSpace(8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon,
                        color: AppColors.primaryColor, size: 16),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.primaryColor.withOpacity(0.1),
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                body,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: context.highText,
                  fontSize: 15,
                  fontFamily: 'Tajawal',
                  height: 1.9,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHintsCard(List<String> hints) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _hintsExpanded = !_hintsExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedRotation(
                    turns: _hintsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.primaryColor, size: 22),
                  ),
                  horizontalSpace(8),
                  const Text(
                    'فوائد الحديث',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 15,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  horizontalSpace(8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_outline_rounded,
                        color: AppColors.primaryColor, size: 16),
                  ),
                ],
              ),
            ),
          ),
          if (_hintsExpanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.primaryColor.withOpacity(0.1),
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: hints.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 11,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        horizontalSpace(10),
                        Expanded(
                          child: Text(
                            e.value,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: context.highText,
                              fontSize: 14,
                              fontFamily: 'Tajawal',
                              height: 1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
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
