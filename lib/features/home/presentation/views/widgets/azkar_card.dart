import 'package:flutter/material.dart';

import '../../../../../core/utils/spacing.dart';

class AzkarCard extends StatefulWidget {
  const AzkarCard({super.key});

  @override
  State<AzkarCard> createState() => _AzkarCardState();
}

class _AzkarCardState extends State<AzkarCard> {
  int currentIndex = 0;

  final List<Map<String, String>> azkarList = [
    {
      "arabic": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
      "english": "Subhan Allahi wa bihamdih",
    },
    {
      "arabic": "سُبْحَانَ اللَّهِ الْعَظِيمِ",
      "english": "Subhan Allahil Azeem",
    },
    {
      "arabic": "اللَّهُ أَكْبَرُ",
      "english": "Allahu Akbar",
    },
    {
      "arabic": "الْـحَمْـدُ للهِ",
      "english": "Alhamdulillah",
    },
    {
      "arabic": "لَا إِلَهَ إِلَّا اللَّهُ",
      "english": "La ilaha illallah",
    },
    {
      "arabic": "أَسْتَغْفِرُ اللَّهَ",
      "english": "Astaghfirullah",
    },
    {
      "arabic": "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
      "english": "Hasbunallahu wa ni'mal wakeel",
    },
    {
      "arabic": "رَبِّ اغْفِرْ لِي",
      "english": "Rabbighfir li",
    },
    {
      "arabic": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ",
      "english": "Allahumma salli ala Muhammad",
    },
    {
      "arabic": "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ",
      "english": "Allahumma inni a'udhu bika",
    },
    {
      "arabic": "اللَّهُمَّ اهْدِنِي",
      "english": "Allahumma ihdini",
    },
    {
      "arabic": "اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ",
      "english": "Allahumma aj'alni min at-tawwabeen",
    },
  ];

  void _next() {
    if (currentIndex < azkarList.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _previous() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = azkarList[currentIndex]['arabic']!;
    final english = azkarList[currentIndex]['english']!;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 221, 246, 235),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: currentIndex == azkarList.length - 1
                              ? Colors.grey
                              : const Color(0xFF6F8F87),
                          shape: BoxShape.circle,
                        ),
                        child: const Directionality(
                          textDirection: TextDirection.ltr,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _previous,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: currentIndex == 0
                              ? Colors.grey
                              : const Color(0xFF6F8F87),
                          shape: BoxShape.circle,
                        ),
                        child: const Directionality(
                          textDirection: TextDirection.ltr,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B7669),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${currentIndex + 1}/${azkarList.length}',
                      style: const TextStyle(
                        color: Color(0xFFFBFDFD),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(20),
            SizedBox(
              width: double.infinity,
              child: Text(
                arabic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2B7669),
                  fontSize: 30,
                  fontFamily: 'Amiri Quran',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.10,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: Text(
                'English: $english',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6F8F87),
                  fontSize: 20,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
