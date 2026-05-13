import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/models/hadith_model.dart';
import 'package:yaqeen_app/features/home/data/repo/hadith_favorite_service.dart';
import 'hadith_detail_screen.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

class HadithFavoritesScreen extends StatefulWidget {
  const HadithFavoritesScreen({super.key});

  @override
  State<HadithFavoritesScreen> createState() => _HadithFavoritesScreenState();
}

class _HadithFavoritesScreenState extends State<HadithFavoritesScreen> {
  List<HadithModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favs = await HadithFavoriteService.getFavorites();
    if (mounted) setState(() { _favorites = favs; _isLoading = false; });
  }

  Future<void> _remove(HadithModel hadith) async {
    await HadithFavoriteService.removeFavorite(hadith.refNo);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('تم الحذف من المفضلة',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
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
          const Spacer(),
          const Text(
            'الأحاديث المحفوظة',
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey[300]),
            verticalSpace(16),
            Text(
              'لا توجد أحاديث محفوظة',
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            verticalSpace(8),
            Text(
              'احفظ الأحاديث التي تعجبك من شاشة الأحاديث',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Tajawal',
                fontSize: 14,
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
            '${_favorites.length} حديث محفوظ',
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
            itemCount: _favorites.length,
            separatorBuilder: (_, __) => verticalSpace(10),
            itemBuilder: (ctx, i) => _FavoriteHadithCard(
              hadith: _favorites[i],
              onRemove: () => _remove(_favorites[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoriteHadithCard extends StatelessWidget {
  final HadithModel hadith;
  final VoidCallback onRemove;

  const _FavoriteHadithCard({required this.hadith, required this.onRemove});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                  ),
                ),
                Row(
                  children: [
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
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF9F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          color: AppColors.primaryColor, size: 16),
                    ),
                  ],
                ),
              ],
            ),
            verticalSpace(12),
            Text(
              hadith.arabicText,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1A2221),
                fontSize: 17,
                fontFamily: 'Amiri Quran',
                height: 1.9,
              ),
            ),
            if (hadith.refNo.isNotEmpty) ...[
              verticalSpace(10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
