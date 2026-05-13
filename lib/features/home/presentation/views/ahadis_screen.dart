import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_favorite_service.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_service.dart';
import 'hadith_favorites_screen.dart';
import 'hadith_search_screen.dart';
import 'hadith_detail_screen.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';

class AhadisScreen extends StatefulWidget {
  const AhadisScreen({super.key});

  @override
  State<AhadisScreen> createState() => _AhadisScreenState();
}

class _AhadisScreenState extends State<AhadisScreen> {
  String _selectedBook = 'bukhari';
  final List<HadithModel> _hadiths = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHadiths(refresh: true);
  }

  Future<void> _loadHadiths({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _hadiths.clear();
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final batch = await HadithService.fetchMultiple(book: _selectedBook, count: 8);
      if (mounted) {
        setState(() {
          _hadiths.addAll(batch);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل الأحاديث، تحقق من الاتصال';
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final batch = await HadithService.fetchMultiple(book: _selectedBook, count: 5);
      if (mounted) {
        setState(() {
          _hadiths.addAll(batch);
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _selectBook(String key) {
    if (_selectedBook == key) return;
    setState(() => _selectedBook = key);
    _loadHadiths(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildBanner(),
            _buildBookTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────── App bar ────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Row(children: [
            _circleBtn(Icons.favorite_border_rounded, () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HadithFavoritesScreen()),
            )),
            horizontalSpace(8),
            _circleBtn(Icons.search_rounded, () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HadithSearchScreen()),
            )),
          ]),
          const Spacer(),
          const Text(
            'الأحاديث الشريفة',
            style: TextStyle(
              color: Color(0xFF2B7669),
              fontSize: 22,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
            ),
          ),
          horizontalSpace(8),
          _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
        ],
      ),
    );
  }

  // ──────────────────────────────────── Banner ─────────────────────────────────

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(children: [
        Container(
          height: 100,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          child: Image.asset(AppImages.hadisBannerWidget, fit: BoxFit.cover),
        ),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [
              const Color(0xFF206B5E).withOpacity(0.82),
              const Color(0xFF1A3A35).withOpacity(0.88),
            ]),
          ),
          child: const Center(
            child: Text(
              'وَمَا يَنْطِقُ عَنِ الْهَوَى إِنْ هُوَ إِلَّا وَحْيٌ يُوحَى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'Amiri Quran',
                height: 1.6,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ──────────────────────────────────── Book tabs ──────────────────────────────

  Widget _buildBookTabs() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: HadithService.books.length,
        separatorBuilder: (_, __) => horizontalSpace(8),
        itemBuilder: (_, i) {
          final book     = HadithService.books[i];
          final selected = _selectedBook == book.key;
          return GestureDetector(
            onTap: () => _selectBook(book.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryColor : const Color(0xFFEAF9F4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )]
                    : null,
              ),
              child: Text(
                book.arabicName,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF2B7669),
                  fontSize: 13,
                  fontFamily: 'Tajawal',
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────── Body ───────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 3),
            ),
            verticalSpace(14),
            const Text(
              'جاري تحميل الأحاديث...',
              style: TextStyle(fontFamily: 'Tajawal', color: AppColors.primaryColor, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _hadiths.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey[300]),
              verticalSpace(14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontFamily: 'Tajawal', fontSize: 15),
              ),
              verticalSpace(20),
              ElevatedButton.icon(
                onPressed: () => _loadHadiths(refresh: true),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('إعادة المحاولة',
                    style: TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: AppColors.primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => _loadHadiths(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _hadiths.length + 1, // +1 for load-more footer
        separatorBuilder: (_, __) => verticalSpace(12),
        itemBuilder: (ctx, i) {
          if (i == _hadiths.length) return _buildLoadMoreButton();
          return _HadithListCard(
            hadith: _hadiths[i],
            index: i + 1,
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: _isLoadingMore
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 2.5),
              ),
            )
          : GestureDetector(
              onTap: _loadMore,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF9F4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.expand_more_rounded, color: AppColors.primaryColor, size: 22),
                    horizontalSpace(8),
                    const Text(
                      'تحميل المزيد',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ──────────────────────────────────── Helpers ────────────────────────────────

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(color: Color(0xFFEAF9F4), shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primaryColor, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual hadith card
// ─────────────────────────────────────────────────────────────────────────────

class _HadithListCard extends StatefulWidget {
  final HadithModel hadith;
  final int index;

  const _HadithListCard({required this.hadith, required this.index});

  @override
  State<_HadithListCard> createState() => _HadithListCardState();
}

class _HadithListCardState extends State<_HadithListCard> {
  bool _isFavorite = false;
  bool _expanded   = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
    final fav = await HadithFavoriteService.isFavorite(widget.hadith.refNo);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFav() async {
    final next = await HadithFavoriteService.toggleFavorite(widget.hadith);
    setState(() => _isFavorite = next);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          next ? '❤️ تم الحفظ في المفضلة' : 'تم الحذف من المفضلة',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: next ? AppColors.primaryColor : Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _share() => Share.share(
      '${widget.hadith.arabicText}\n\n— ${widget.hadith.bookName} (${widget.hadith.refNo})');

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.hadith.arabicText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('تم نسخ الحديث',
          textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: AppColors.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hadith    = widget.hadith;
    final textLines = hadith.arabicText.split(' ').length;
    final isLong    = textLines > 30; // roughly 3+ lines

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HadithDetailScreen(hadith: hadith)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── header bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.06),
                    AppColors.primaryColor.withOpacity(0.03),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // index badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // book name
                  Text(
                    hadith.bookName,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  horizontalSpace(8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: AppColors.primaryColor, size: 16),
                  ),
                ],
              ),
            ),

            // ── arabic text ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hadith.arabicText,
                    textAlign: TextAlign.right,
                    maxLines: _expanded ? null : (isLong ? 4 : null),
                    overflow: _expanded ? null : (isLong ? TextOverflow.ellipsis : null),
                    style: const TextStyle(
                      color: Color(0xFF1A2221),
                      fontSize: 19,
                      fontFamily: 'Amiri Quran',
                      height: 2.0,
                    ),
                  ),
                  if (isLong) ...[
                    verticalSpace(6),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded ? 'عرض أقل' : 'عرض الكامل',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 13,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── divider ──
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.primaryColor.withOpacity(0.08),
              indent: 16,
              endIndent: 16,
            ),

            // ── action bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // ref number
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF9F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hadith.refNo,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // actions
                  _iconAction(
                    icon: Icons.copy_rounded,
                    tooltip: 'نسخ',
                    onTap: _copy,
                  ),
                  horizontalSpace(4),
                  _iconAction(
                    icon: Icons.share_rounded,
                    tooltip: 'مشاركة',
                    onTap: _share,
                  ),
                  horizontalSpace(4),
                  _iconAction(
                    icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                    tooltip: _isFavorite ? 'محفوظ' : 'حفظ',
                    onTap: _toggleFav,
                    color: _isFavorite ? Colors.red : AppColors.primaryColor,
                    filled: _isFavorite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = AppColors.primaryColor,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: filled ? color.withOpacity(0.12) : const Color(0xFFEAF9F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}
