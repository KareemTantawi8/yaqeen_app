import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/home/data/models/hadeethenc_models.dart';
import 'package:yaqeen_app/features/home/data/repo/hadeethenc_service.dart';
import 'hadeethenc_detail_screen.dart';
import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

class HadithTopicScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final int categoryCount;
  final Color categoryColor;
  final IconData categoryIcon;

  const HadithTopicScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryCount,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<HadithTopicScreen> createState() => _HadithTopicScreenState();
}

class _HadithTopicScreenState extends State<HadithTopicScreen> {
  final List<HadeethEncListItem> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    try {
      if (page == 1) {
        setState(() { _isLoading = true; _error = null; });
      } else {
        setState(() => _isLoadingMore = true);
      }
      final result = await HadeethEncService.fetchHadiths(
        widget.categoryId,
        page: page,
        perPage: 15,
      );
      if (mounted) {
        setState(() {
          if (page == 1) _items.clear();
          _items.addAll(result.data);
          _currentPage = result.currentPage;
          _lastPage = result.lastPage;
          _totalItems = result.totalItems;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.categoryColor;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildHeader(color),
            Expanded(child: _buildBody(color)),
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
          const Spacer(),
          Text(
            widget.categoryTitle,
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
              child: const Icon(Icons.arrow_forward_ios_sharp,
                  color: AppColors.primaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isLoading
                    ? '...'
                    : '$_totalItems حديث',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  widget.categoryTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                horizontalSpace(10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(widget.categoryIcon, color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Color color) {
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
                'تعذّر تحميل الأحاديث',
                style: TextStyle(
                  color: context.highText,
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              verticalSpace(20),
              GestureDetector(
                onTap: () => _loadPage(1),
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: _items.length + 1,
      itemBuilder: (ctx, i) {
        if (i < _items.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HadithListTile(
              item: _items[i],
              index: i + 1,
              color: color,
            ),
          );
        }
        // Footer: load more or end indicator
        if (_currentPage < _lastPage) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _isLoadingMore
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryColor))
                : Center(
                    child: GestureDetector(
                      onTap: () => _loadPage(_currentPage + 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 13),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: color.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.expand_more_rounded,
                                color: color, size: 20),
                            horizontalSpace(6),
                            Text(
                              'تحميل المزيد',
                              style: TextStyle(
                                color: color,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'تم عرض جميع الأحاديث',
              style: TextStyle(
                color: context.greyText400,
                fontFamily: 'Tajawal',
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────

class _HadithListTile extends StatelessWidget {
  final HadeethEncListItem item;
  final int index;
  final Color color;

  const _HadithListTile({
    required this.item,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HadeethEncDetailScreen(
              hadithId: item.id,
              hadithTitle: item.title,
              accentColor: color,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border(
              right: BorderSide(color: color, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 18, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                horizontalSpace(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.title,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.highText,
                          fontSize: 15,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          height: 1.55,
                        ),
                      ),
                      verticalSpace(10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 12,
                            color: color.withOpacity(0.8),
                          ),
                          horizontalSpace(4),
                          Text(
                            'قراءة الحديث',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
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
