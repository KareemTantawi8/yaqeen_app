import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/models/hadeethenc_models.dart';
import 'package:yaqeen_app/features/home/data/repo/hadeethenc_service.dart';
import 'hadith_topic_screen.dart';
import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

const _kColors = [
  Color(0xFF1565C0),
  Color(0xFF6A1B9A),
  Color(0xFF1A5F54),
  Color(0xFF558B2F),
  Color(0xFF00838F),
  Color(0xFFAD1457),
  Color(0xFF37474F),
  Color(0xFF4527A0),
  Color(0xFF00695C),
  Color(0xFF6D4C41),
];

const _kIcons = [
  Icons.auto_stories_rounded,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.balance_rounded,
  Icons.people_rounded,
  Icons.campaign_rounded,
  Icons.history_edu_rounded,
  Icons.menu_book_rounded,
  Icons.lightbulb_outline_rounded,
  Icons.mosque_rounded,
];

Color _color(int i) => _kColors[i % _kColors.length];
IconData _icon(int i) => _kIcons[i % _kIcons.length];

class HadithSearchScreen extends StatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  State<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends State<HadithSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<HadeethEncCategory> _allCategories = [];
  List<HadeethEncCategory> _results = [];
  bool _isFetchingCategories = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _prefetchCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _prefetchCategories() async {
    setState(() => _isFetchingCategories = true);
    try {
      final cats = await HadeethEncService.fetchAllCategories();
      if (mounted) setState(() { _allCategories = cats; _isFetchingCategories = false; });
    } catch (_) {
      if (mounted) setState(() => _isFetchingCategories = false);
    }
  }

  void _search() {
    final query = _controller.text.trim();
    _focusNode.unfocus();
    if (query.isEmpty) return;
    setState(() {
      _hasSearched = true;
      _results = _allCategories
          .where((c) => c.title.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
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
          Text(
            'البحث في الأحاديث',
            style: TextStyle(
              color: context.brandText,
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
              decoration: BoxDecoration(
                color: context.lightAccent,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                hintText: 'ابحث عن موضوع...',
                hintStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: Color(0xFFAAAAAA),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: context.lightAccent,
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
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.primaryColor, size: 22),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isFetchingCategories && !_hasSearched) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryColor),
          verticalSpace(16),
          Text(
            'جارٍ تحميل فهرس الموضوعات...',
            style: TextStyle(
              color: context.greyText500,
              fontFamily: 'Tajawal',
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 72, color: context.greyText300),
            verticalSpace(16),
            Text(
              'ابحث في موضوعات الأحاديث',
              style: TextStyle(
                color: context.greyText500,
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            verticalSpace(8),
            Text(
              'مثال: صلاة، زكاة، توبة، أخلاق...',
              style: TextStyle(
                color: context.greyText400,
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
            Icon(Icons.search_off_rounded, size: 72, color: context.greyText300),
            verticalSpace(16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                color: context.greyText500,
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            verticalSpace(8),
            Text(
              'جرب كلمة بحث مختلفة',
              style: TextStyle(
                color: context.greyText400,
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
            'تم إيجاد ${_results.length} موضوع',
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
            itemBuilder: (ctx, i) =>
                _CategoryResultCard(category: _results[i], colorIndex: i),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────

class _CategoryResultCard extends StatelessWidget {
  final HadeethEncCategory category;
  final int colorIndex;

  const _CategoryResultCard({
    required this.category,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final color = _color(colorIndex);
    final icon = _icon(colorIndex);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HadithTopicScreen(
            categoryId: category.id,
            categoryTitle: category.title,
            categoryCount: category.hadeethsCount,
            categoryColor: color,
            categoryIcon: icon,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.chevron_left_rounded,
                color: AppColors.primaryColor, size: 20),
            const Spacer(),
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    category.title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: context.highText,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  verticalSpace(6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${category.hadeethsCount} حديث',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            horizontalSpace(12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
