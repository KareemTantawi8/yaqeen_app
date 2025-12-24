class Surah {
  final int number;
  final String name; // Arabic name
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType; // Meccan or Medinan

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
    };
  }

  // Helper getters for backward compatibility
  String get arabic => name;
  String get english => englishName;
  int get ayahs => numberOfAyahs;
  String get type => revelationType == 'Meccan' ? 'مكية' : 'مدنية';
}
