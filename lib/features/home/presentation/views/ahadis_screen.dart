import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/models/hadeethenc_models.dart';
import 'package:yaqeen_app/features/home/data/repo/hadeethenc_service.dart';
import 'hadith_favorites_screen.dart';
import 'hadith_search_screen.dart';
import 'hadith_topic_screen.dart';
import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';

// Colours and icons mapped to the 7 root categories by index
const _kCategoryColors = [
  Color(0xFF1565C0),
  Color(0xFF6A1B9A),
  Color(0xFF1A5F54),
  Color(0xFF558B2F),
  Color(0xFF00838F),
  Color(0xFFAD1457),
  Color(0xFF37474F),
];

const _kCategoryIcons = [
  Icons.auto_stories_rounded,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.balance_rounded,
  Icons.people_rounded,
  Icons.campaign_rounded,
  Icons.history_edu_rounded,
];

Color _colorAt(int i) => _kCategoryColors[i % _kCategoryColors.length];
IconData _iconAt(int i) => _kCategoryIcons[i % _kCategoryIcons.length];

class AhadisScreen extends StatefulWidget {
  const AhadisScreen({super.key});

  @override
  State<AhadisScreen> createState() => _AhadisScreenState();
}

class _AhadisScreenState extends State<AhadisScreen> {
  List<HadeethEncCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final cats = await HadeethEncService.fetchRootCategories();
      if (mounted) setState(() { _categories = cats; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildBanner(),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Row(
            children: [
              _circleBtn(
                context,
                Icons.favorite_border_rounded,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HadithFavoritesScreen(),
                  ),
                ),
              ),
              horizontalSpace(8),
              _circleBtn(
                context,
                Icons.search_rounded,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HadithSearchScreen()),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'الأحاديث الشريفة',
            style: TextStyle(
              color: context.brandText,
              fontSize: 22,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
            ),
          ),
          horizontalSpace(8),
          _circleBtn(
            context,
            Icons.arrow_forward_ios_sharp,
            () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: Image.asset(AppImages.hadisBannerWidget, fit: BoxFit.cover),
          ),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF206B5E).withOpacity(0.82),
                  const Color(0xFF1A3A35).withOpacity(0.88),
                ],
              ),
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
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
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
                  size: 72, color: AppColors.primaryColor),
              verticalSpace(16),
              Text(
                'تعذّر الاتصال',
                style: TextStyle(
                  color: context.highText,
                  fontSize: 18,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                ),
              ),
              verticalSpace(8),
              Text(
                'تحقق من الاتصال بالإنترنت ثم أعد المحاولة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.greyText500,
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                ),
              ),
              verticalSpace(24),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _buildTopicsGrid(context);
  }

  Widget _buildTopicsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            'اختر موضوعاً',
            style: TextStyle(
              color: context.brandText,
              fontSize: 16,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final color = _colorAt(i);
              final icon = _iconAt(i);
              return _CategoryCard(
                category: cat,
                color: color,
                icon: icon,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _circleBtn(
      BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: context.lightAccent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 22),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final HadeethEncCategory category;
  final Color color;
  final IconData icon;

  const _CategoryCard({
    required this.category,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              left: -18,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    category.title,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.highText,
                      fontSize: 15,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  verticalSpace(6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${category.hadeethsCount} حديث',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
