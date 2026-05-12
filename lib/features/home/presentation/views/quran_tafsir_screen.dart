import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart' as qwt;
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/utils/spacing.dart';

class QuranTafsirScreen extends StatefulWidget {
  static const String routeName = '/quran_tafsir';

  const QuranTafsirScreen({super.key});

  @override
  State<QuranTafsirScreen> createState() => _QuranTafsirScreenState();
}

class _QuranTafsirScreenState extends State<QuranTafsirScreen> {
  late List<qwt.SurahMetadata> surahs;
  bool isLoading = true;
  bool isTafsirLoading = false;
  int? selectedSurahNumber;
  Map<int, String>? tafsirMap;

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

  void _loadTafsir(int surahNumber) async {
    try {
      setState(() {
        isTafsirLoading = true;
      });

      final quranService = qwt.QuranService.instance;
      final tafsir = quranService.getTafsir(surahNumber);
      setState(() {
        selectedSurahNumber = surahNumber;
        tafsirMap = tafsir;
        isTafsirLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load tafsir: $e');
      setState(() {
        isTafsirLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل التفسير')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('التفسير'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedSurahNumber == null)
                    Center(
                      child: Column(
                        children: [
                          verticalSpace(20),
                          Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: AppColors.primaryColor,
                          ),
                          verticalSpace(16),
                          Text(
                            'اختر سورة لقراءة تفسيرها',
                            style: TextStyles.font16PrimaryText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (selectedSurahNumber != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              surahs[selectedSurahNumber! - 1].nameAr,
                              style: TextStyles.font16PrimaryText.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSurahNumber = null;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (selectedSurahNumber == null)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                  style: TextStyles.font12WhiteText.copyWith(
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
                            onTap: () => _loadTafsir(surah.number),
                          ),
                        );
                      },
                    ),
                  if (selectedSurahNumber != null)
                    if (isTafsirLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else
                      _buildTafsirContent(selectedSurahNumber!),
                  verticalSpace(40),
                ],
              ),
            ),
    );
  }

  Widget _buildTafsirContent(int surahNumber) {
    final quranService = qwt.QuranService.instance;
    final surah = quranService.getSurah(surahNumber);
    final verses = surah.verses;

    if (tafsirMap == null || tafsirMap!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'لا يوجد تفسير متاح لهذه السورة',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        final tafsir = tafsirMap?[verse.id];

        if (tafsir == null) return const SizedBox();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'الآية ${verse.id}',
                    style: TextStyles.font12PrimaryText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                verticalSpace(8),
                Text(
                  verse.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Amiri Quran',
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                ),
                verticalSpace(12),
                Divider(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  thickness: 1,
                ),
                verticalSpace(8),
                Text(
                  tafsir,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
