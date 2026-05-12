import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart' as qwt;
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/styles/images/app_image.dart';
import '../../../../core/utils/spacing.dart';
import '../../data/models/surah_model.dart';
import 'widgets/recent_quran_read.dart';
import 'surah_detail_screen.dart';

class QuranReadScreen extends StatefulWidget {
  static const String routeName = '/quran_read';

  const QuranReadScreen({super.key});

  @override
  State<QuranReadScreen> createState() => _QuranReadScreenState();
}

class _QuranReadScreenState extends State<QuranReadScreen> {
  late List<qwt.SurahMetadata> surahs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  void _loadSurahs() async {
    try {
      final quranService = qwt.QuranService.instance;
      setState(() {
        surahs = quranService.getAllSurahs();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load surahs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('القرآن الكريم'),
            Text(
              'القراءة',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with recent read
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RecentQuranRead(),
                      verticalSpace(24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'السور',
                          style: TextStyles.font18PrimaryText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),

                // Surahs list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${surah.number}',
                                style: TextStyles.font14WhiteText.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            surah.nameAr,
                            style: TextStyles.font16PrimaryText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${surah.ayahCount} آية',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            final appSurah = Surah(
                              number: surah.number,
                              name: surah.nameAr,
                              englishName: surah.nameEn,
                              englishNameTranslation: '',
                              numberOfAyahs: surah.ayahCount,
                              revelationType: surah.revelationType ?? 'Unknown',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SurahDetailScreen(
                                  surah: appSurah,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
