import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../../../core/extension/context_extension.dart';
import '../../../core/utils/quran_text_utils.dart';
import '../../../core/styles/colors/app_color.dart';

class AyahSelectionSheet extends StatelessWidget {
  const AyahSelectionSheet({
    super.key,
    required this.ayahs,
    required this.pageNumber,
    required this.onAyahSelected,
  });

  final List<Ayah> ayahs;
  final int pageNumber;
  final void Function(Ayah ayah, String surahName) onAyahSelected;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.greyText300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: AppColors.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'آيات الصفحة $pageNumber',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: context.dividerColor),

            // Ayah list
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: ayahs.length,
                separatorBuilder: (context, index) =>
                    Divider(color: context.dividerColor, height: 12),
                itemBuilder: (context, index) {
                  final ayah = ayahs[index];
                  final surahName =
                      QuranService.instance.getSurahNameArabic(ayah.surahNumber);
                  return _AyahTile(
                    ayah: ayah,
                    surahName: surahName,
                    onTap: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onAyahSelected(ayah, surahName);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahTile extends StatelessWidget {
  const _AyahTile({
    required this.ayah,
    required this.surahName,
    required this.onTap,
  });

  final Ayah ayah;
  final String surahName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cleanedText = QuranTextUtils.withoutAyahMarkers(ayah.text);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.chevron_right, color: context.greyText400, size: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$surahName : ${ayah.id}',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              cleanedText.length > 120
                  ? '${cleanedText.substring(0, 120)}...'
                  : cleanedText,
              style: TextStyle(
                fontFamily: 'Amiri Quran',
                fontSize: 18,
                color: context.highText,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
