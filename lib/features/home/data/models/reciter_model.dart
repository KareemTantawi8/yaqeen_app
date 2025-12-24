class Reciter {
  final String identifier;
  final String name;
  final String englishName;
  final String format;
  final String language;

  Reciter({
    required this.identifier,
    required this.name,
    required this.englishName,
    required this.format,
    required this.language,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      identifier: json['identifier'] as String,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      format: json['format'] as String? ?? 'audio',
      language: json['language'] as String? ?? 'ar',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'englishName': englishName,
      'format': format,
      'language': language,
    };
  }
}

// Popular reciters list
class RecitersList {
  static final List<Reciter> popular = [
    Reciter(
      identifier: 'ar.alafasy',
      name: 'مشاري العفاسي',
      englishName: 'Mishari Rashid al-`Afasy',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.abdulbasitmurattal',
      name: 'عبد الباسط عبد الصمد - مرتل',
      englishName: 'Abdul Basit - Murattal',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.abdullahbasfar',
      name: 'عبدالله بصفر',
      englishName: 'Abdullah Basfar',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.abdurrahmaansudais',
      name: 'عبد الرحمن السديس',
      englishName: 'AbdulRahman Al-Sudais',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.mahermuaiqly',
      name: 'ماهر المعيقلي',
      englishName: 'Maher Al Muaiqly',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.husary',
      name: 'محمود خليل الحصري',
      englishName: 'Mahmoud Khalil Al-Hussary',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.minshawi',
      name: 'محمد صديق المنشاوي',
      englishName: 'Mohamed Siddiq al-Minshawi',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.shaatree',
      name: 'أبو بكر الشاطري',
      englishName: 'Abu Bakr al-Shatri',
      format: 'audio',
      language: 'ar',
    ),
  ];
}

