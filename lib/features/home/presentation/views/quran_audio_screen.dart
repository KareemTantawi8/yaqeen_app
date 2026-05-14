import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart' as qwt;
import 'package:just_audio/just_audio.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/styles/fonts/font_styles.dart';
import '../../../../core/utils/spacing.dart';

class QuranAudioScreen extends StatefulWidget {
  static const String routeName = '/quran_audio';

  const QuranAudioScreen({super.key});

  @override
  State<QuranAudioScreen> createState() => _QuranAudioScreenState();
}

class _QuranAudioScreenState extends State<QuranAudioScreen> {
  late List<qwt.SurahMetadata> surahs;
  bool isLoading = true;
  String selectedReciter = 'Alafasy_128kbps';
  int? selectedSurahNumber;
  int currentAyah = 1;
  bool isPlaying = false;

  final AudioPlayer audioPlayer = AudioPlayer();

  final List<String> reciters = [
    'Alafasy_128kbps',
    'Abdul_Basit_Mujawwad_128kbps',
    'Abdurrahmaan_As-Sudais_192kbps',
    'Mishari_Alafasy_192kbps',
  ];

  final List<String> reciterNames = [
    'مشاري العفاسي',
    'عبدالباسط مجود',
    'عبدالرحمن السديس',
    'مشاري العفاسي HD',
  ];

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

  Future<void> _playAyah(int surahNumber, int ayahNumber) async {
    try {
      final quranService = qwt.QuranService.instance;
      final audioUrl = quranService.getAudioUrl(
        surahNumber,
        ayahNumber,
        reciterIdentifier: selectedReciter,
      );
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(audioUrl)),
      );
      await audioPlayer.play();
      setState(() {
        selectedSurahNumber = surahNumber;
        currentAyah = ayahNumber;
        isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _pauseAudio() async {
    await audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _resumeAudio() async {
    await audioPlayer.play();
    setState(() {
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
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
              'الاستماع',
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
                // Header with reciter selector and now-playing card
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reciter Selector
                      Text(
                        'اختر القارئ',
                        style: TextStyles.font16PrimaryText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      verticalSpace(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedReciter,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: List.generate(
                            reciters.length,
                            (index) => DropdownMenuItem(
                              value: reciters[index],
                              child: Text(reciterNames[index]),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedReciter = value!;
                            });
                          },
                        ),
                      ),
                      verticalSpace(20),

                      // Now Playing Card
                      if (selectedSurahNumber != null)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الآن يتم التشغيل',
                                  style: TextStyles.font12PrimaryText.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                verticalSpace(8),
                                Text(
                                  surahs[selectedSurahNumber! - 1].nameAr,
                                  style: TextStyles.font16PrimaryText.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                verticalSpace(4),
                                Text(
                                  'القارئ: ${reciterNames[reciters.indexOf(selectedReciter)]}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      verticalSpace(24),

                      // Surah List Header
                      Text(
                        'السور',
                        style: TextStyles.font16PrimaryText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),

                // Surahs List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];
                      final isSelected = selectedSurahNumber == surah.number;

                      return Card(
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.white,
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
                          subtitle: Text(
                            '${surah.ayahCount} آية',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            isSelected && isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: AppColors.primaryColor,
                            size: 28,
                          ),
                          onTap: () {
                            if (isSelected && isPlaying) {
                              _pauseAudio();
                            } else if (isSelected && !isPlaying) {
                              _resumeAudio();
                            } else {
                              _playAyah(surah.number, 1);
                            }
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
