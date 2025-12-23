import 'package:flutter/material.dart';
import '../../../../../core/common/widgets/launch_utils.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/book_model.dart';

class BookWidget extends StatelessWidget {
  const BookWidget({
    super.key,
    required this.book,
    required this.onTap,
  });

  final BookModel book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: book.hasUrl ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Header with Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  horizontalSpace(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            color: Color(0xFF1A2221),
                            fontSize: 18,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.authors.isNotEmpty) ...[
                          verticalSpace(8),
                          Text(
                            book.authors.map((a) => a.title).join('، '),
                            style: const TextStyle(
                              color: Color(0xFF6F8F87),
                              fontSize: 14,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Book Description
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.description.isNotEmpty) ...[
                    Text(
                      book.description,
                      style: const TextStyle(
                        color: Color(0xFF475466),
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    verticalSpace(16),
                  ],
                  
                  // Attachment Info
                  if (book.attachments.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          size: 16,
                          color: AppColors.primaryColor.withOpacity(0.7),
                        ),
                        horizontalSpace(8),
                        Text(
                          '${book.attachments.length} ${book.attachments.length == 1 ? 'ملف' : 'ملفات'}',
                          style: TextStyle(
                            color: AppColors.primaryColor.withOpacity(0.7),
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (book.attachments.first.size.isNotEmpty) ...[
                          horizontalSpace(8),
                          Text(
                            '• ${book.attachments.first.size}',
                            style: TextStyle(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              fontSize: 12,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ],
                    ),
                    verticalSpace(16),
                  ],
                  
                  // Action Button or No URL Message
                  if (book.hasUrl)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'فتح الكتاب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          horizontalSpace(8),
                          const Icon(
                            Icons.open_in_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.withOpacity(0.7),
                            size: 20,
                          ),
                          horizontalSpace(8),
                          Text(
                            'الكتاب غير متاح حالياً',
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 14,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

