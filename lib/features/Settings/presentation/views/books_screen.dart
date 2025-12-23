import 'package:flutter/material.dart';
import '../../../../core/common/widgets/custom_loading_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/common/widgets/launch_utils.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';
import '../../data/models/book_model.dart';
import '../../data/repo/books_load_data.dart';
import 'widgets/book_widget.dart';

class BooksScreen extends StatefulWidget {
  static const String routeName = '/books';
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<BookModel> books = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    loadBooks(page: 1);
  }

  Future<void> loadBooks({required int page}) async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
        currentPage = page;
      });

      final response = await BooksLoadData.loadBooks(
        page: page,
        limit: 10,
      );

      setState(() {
        books = response.books;
        currentPage = response.currentPage;
        totalPages = response.totalPages;
        totalItems = response.totalItems;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load books: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل الكتب. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages && page != currentPage) {
      loadBooks(page: page);
      // Scroll to top when changing pages
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          // Scroll to top if we have a scroll controller
        }
      });
    }
  }

  Future<void> openBook(BookModel book) async {
    final url = book.pdfUrl;
    if (url != null) {
      await launchExternalUrl(url, context);
    }
  }

  Widget _buildPaginationWidget() {
    // Calculate which page numbers to show
    List<int> pagesToShow = [];
    
    if (totalPages <= 7) {
      // Show all pages if 7 or fewer
      pagesToShow = List.generate(totalPages, (index) => index + 1);
    } else {
      // Show first page, last page, current page, and pages around current
      if (currentPage <= 3) {
        // Show first 5 pages and last page
        pagesToShow = [1, 2, 3, 4, 5, -1, totalPages]; // -1 represents ellipsis
      } else if (currentPage >= totalPages - 2) {
        // Show first page and last 5 pages
        pagesToShow = [1, -1, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
      } else {
        // Show first page, ellipsis, current-1, current, current+1, ellipsis, last page
        pagesToShow = [1, -1, currentPage - 1, currentPage, currentPage + 1, -1, totalPages];
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          if (currentPage > 1)
            InkWell(
              onTap: () => _goToPage(currentPage - 1),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
            ),
          
          horizontalSpace(8),
          
          // Page numbers
          ...pagesToShow.map((page) {
            if (page == -1) {
              // Ellipsis
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    color: AppColors.primaryColor.withOpacity(0.5),
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                  ),
                ),
              );
            }
            
            final isCurrentPage = page == currentPage;
            return InkWell(
              onTap: () => _goToPage(page),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrentPage
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentPage
                      ? null
                      : Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    color: isCurrentPage
                        ? Colors.white
                        : AppColors.primaryColor,
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                    fontWeight: isCurrentPage
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
          
          horizontalSpace(8),
          
          // Next button
          if (currentPage < totalPages)
            InkWell(
              onTap: () => _goToPage(currentPage + 1),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const DefaultAppBar(
                title: 'الكتب الإسلامية',
                icon: Icons.arrow_back,
              ),
              verticalSpace(16),
              Expanded(
                child: isLoading
                    ? const CustomLoadingWidget(
                        message: 'جاري تحميل الكتب...',
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
                                  onPressed: () => loadBooks(page: currentPage),
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
                        : books.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا توجد كتب متاحة',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () => loadBooks(page: currentPage),
                                      color: AppColors.primaryColor,
                                      child: ListView.builder(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: books.length,
                                        itemBuilder: (context, index) {
                                          final book = books[index];
                                          return BookWidget(
                                            book: book,
                                            onTap: () => openBook(book),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Pagination Widget
                                  if (totalPages > 1) ...[
                                    verticalSpace(16),
                                    _buildPaginationWidget(),
                                    verticalSpace(8),
                                  ],
                                ],
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 