import 'package:flutter/material.dart';
import 'package:yaqeen_app/core/common/widgets/custom_divider_widget.dart';
import 'package:yaqeen_app/core/common/widgets/custom_loading_widget.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';
import 'package:yaqeen_app/features/Azkar/data/model/adhkar_category_model.dart';
import 'package:yaqeen_app/features/Azkar/data/repo/askar_load_data.dart';
import 'package:yaqeen_app/features/Azkar/presentation/views/widgets/askar_image_banner.dart';
import 'package:yaqeen_app/features/Azkar/presentation/views/widgets/askar_list_view.dart';
import 'package:yaqeen_app/features/Azkar/presentation/views/widgets/azkar_app_bar_widget.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  List<AdhkarCategoryModel> categories = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAzkar();
  }

  Future<void> loadAzkar() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      final response = await AzkarService.loadAzkar();

      setState(() {
        categories = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load azkar: $e');
      debugPrint('Error details: ${e.toString()}');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل الأذكار: ${e.toString().split(':').first}\nيرجى المحاولة مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const AzkarAppBarWidget(),
              verticalSpace(6),
              const CustomDividerWidget(),
              verticalSpace(6),
              const AzkarImageBanner(),
              verticalSpace(8),
              Expanded(
                child: isLoading
                    ? const CustomLoadingWidget(
                        message: 'جاري تحميل الأذكار...',
                        size: 100.0,
                      )
                    : hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.errorColor,
                                ),
                                verticalSpace(16),
                                Text(
                                  errorMessage ?? 'حدث خطأ',
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontFamily: 'Tajawal',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                verticalSpace(24),
                                ElevatedButton(
                                  onPressed: loadAzkar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'إعادة المحاولة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : categories.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا توجد أذكار متاحة',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              )
                            : AskarListView(
                                categories: categories,
                                onRefresh: loadAzkar,
                              ),
              ),
              verticalSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
