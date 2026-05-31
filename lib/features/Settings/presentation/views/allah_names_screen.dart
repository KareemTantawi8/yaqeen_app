import 'package:flutter/material.dart';
import 'package:yaqeen_app/features/Settings/presentation/views/widgets/allah_names_widget.dart';
import '../../../../core/common/widgets/custom_loading_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/extension/context_extension.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';
import '../../data/models/allah_name_model.dart';
import '../../data/repo/all_name_load_data.dart';

class AllahNamesScreen extends StatefulWidget {
  static const String routeName = '/allah-names';
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  List<AllahNameModel> allahNames = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllahNames();
  }

  Future<void> _loadAllahNames() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });
      final names = await AllNamesLoadData.loadFromAssets();
      setState(() {
        allahNames = names;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل البيانات. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  void _showNameDetail(AllahNameModel name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NameDetailSheet(model: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const DefaultAppBar(
                title: 'أسماء الله الحسنى',
                icon: Icons.arrow_forward_ios_sharp,
              ),
              verticalSpace(8),
              // Subtitle counter
              if (!isLoading && !hasError && allahNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${allahNames.length} اسماً من أسماء الله الحسنى',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: context.secondaryText,
                      fontSize: 13,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              Expanded(
                child: isLoading
                    ? const CustomLoadingWidget(
                        message: 'جاري تحميل أسماء الله الحسنى...',
                        size: 100.0,
                      )
                    : hasError
                        ? _ErrorView(
                            message: errorMessage ?? 'حدث خطأ',
                            onRetry: _loadAllahNames,
                          )
                        : allahNames.isEmpty
                            ? Center(
                                child: Text(
                                  'لا توجد بيانات',
                                  style: TextStyle(
                                    color: context.secondaryText,
                                    fontSize: 16,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              )
                            : GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.72,
                                ),
                                itemCount: allahNames.length,
                                itemBuilder: (context, index) {
                                  final item = allahNames[index];
                                  return AllahNamesWidget(
                                    id: item.id,
                                    name: item.name,
                                    text: item.text,
                                    onTap: () => _showNameDetail(item),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
          verticalSpace(16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace(24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameDetailSheet extends StatelessWidget {
  const _NameDetailSheet({required this.model});
  final AllahNameModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          verticalSpace(24),
          // Number badge
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${model.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          verticalSpace(16),
          // Arabic name
          Text(
            model.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 40,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.w700,
            ),
          ),
          verticalSpace(20),
          // Divider
          Divider(color: context.dividerColor, thickness: 1),
          verticalSpace(16),
          // Full description
          Text(
            model.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: context.highText,
              fontSize: 15,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w400,
              height: 1.7,
            ),
          ),
          verticalSpace(24),
        ],
      ),
    );
  }
}
