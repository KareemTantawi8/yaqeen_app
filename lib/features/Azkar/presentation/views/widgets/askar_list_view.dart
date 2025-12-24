import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../data/model/adhkar_category_model.dart';
import 'adhkar_category_detail_screen.dart';

class AskarListView extends StatelessWidget {
  final List<AdhkarCategoryModel> categories;
  final Future<void> Function()? onRefresh;

  const AskarListView({
    super.key,
    required this.categories,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: categories.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          index: index,
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.primaryColor,
        child: listView,
      );
    }

    return listView;
  }
}

class _CategoryCard extends StatelessWidget {
  final AdhkarCategoryModel category;
  final int index;

  const _CategoryCard({
    required this.category,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEAF9F4),
            const Color(0xFFEAF9F4).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdhkarCategoryDetailScreen(
                  category: category,
                  categoryIndex: index,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Number circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.category,
                        style: const TextStyle(
                          color: Color(0xFF1A2221),
                          fontSize: 18,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.primaryColor.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${category.items.length} ذكر',
                            style: TextStyle(
                              color: AppColors.primaryColor.withOpacity(0.7),
                              fontSize: 14,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
