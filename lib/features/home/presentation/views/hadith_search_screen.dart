import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_service.dart';
import 'hadith_detail_screen.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

class HadithSearchScreen extends StatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  State<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends State<HadithSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<HadithModel> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    _focusNode.unfocus();
    setState(() { _isSearching = true; _hasSearched = true; _results = []; });

    final allHadiths = <HadithModel>[];
    for (final book in HadithService.books) {
      try {
        final hadiths = await HadithService.fetchMultiple(book: book.key, count: 3);
        allHadiths.addAll(hadiths);
      } catch (_) {}
    }

    final lower = query.toLowerCase();
    final results = allHadiths.where((h) =>
      h.arabicText.contains(query) ||
      h.chapter.contains(query) ||
      h.englishText.toLowerCase().contains(lower) ||
      h.bookName.contains(query)
    ).toList();

    setState(() { _results = results; _isSearching = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
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
          const Spacer(),
          const Text(
            'البحث في الأحاديث',
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
              child: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _search,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'بحث',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          horizontalSpace(10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15),
              decoration: InputDecoration(
                hintText: 'ابحث في متن الحديث...',
                hintStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: Color(0xFFAAAAAA),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFEAF9F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor, size: 22),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryColor),
            verticalSpace(16),
            const Text(
              'جاري البحث في الأحاديث...',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 72, color: Colors.grey[300]),
            verticalSpace(16),
            Text(
              'ابحث في الأحاديث الشريفة',
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            verticalSpace(8),
            Text(
              'أدخل كلمة أو جزء من متن الحديث',
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Tajawal',
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 72, color: Colors.grey[300]),
            verticalSpace(16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            verticalSpace(8),
            Text(
              'جرب كلمة بحث مختلفة',
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Tajawal',
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'تم إيجاد ${_results.length} نتيجة',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _results.length,
            separatorBuilder: (_, __) => verticalSpace(10),
            itemBuilder: (ctx, i) => _HadithSearchResultCard(hadith: _results[i]),
          ),
        ),
      ],
    );
  }
}

class _HadithSearchResultCard extends StatelessWidget {
  final HadithModel hadith;
  const _HadithSearchResultCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HadithDetailScreen(hadith: hadith)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Book badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF9F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hadith.refNo.isNotEmpty ? hadith.refNo : '—',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 11,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  hadith.bookName,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            verticalSpace(10),
            Text(
              hadith.arabicText,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1A2221),
                fontSize: 16,
                fontFamily: 'Amiri Quran',
                height: 1.9,
              ),
            ),
            if (hadith.chapter.isNotEmpty) ...[
              verticalSpace(8),
              Text(
                hadith.chapter,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6F8F87),
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
            verticalSpace(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'اقرأ الحديث كاملاً',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                horizontalSpace(4),
                const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
