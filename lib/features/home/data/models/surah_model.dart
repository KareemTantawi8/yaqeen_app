class Surah {
  final int number;
  final String arabic;
  final String english;
  final int ayahs;
  final String type;

  Surah({
    required this.number,
    required this.arabic,
    required this.english,
    required this.ayahs,
    required this.type,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      arabic: json['arabic'],
      english: json['english'],
      ayahs: json['ayahs'],
      type: json['type'],
    );
  }
}
