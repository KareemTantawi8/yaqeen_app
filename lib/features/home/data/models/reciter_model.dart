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
  // Reciters compatible with everyayah.com API
  static final List<Reciter> popular = [
    Reciter(
      identifier: 'Alafasy_128kbps',
      name: 'مشاري العفاسي',
      englishName: 'Mishari Rashid al-`Afasy',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Abdul_Basit_Mujawwad_128kbps',
      name: 'عبد الباسط عبد الصمد (مجود)',
      englishName: 'Abdul Basit (Mujawwad)',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Abdul_Basit_Murattal_64kbps',
      name: 'عبد الباسط عبد الصمد (مرتل)',
      englishName: 'Abdul Basit (Murattal)',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Abdurrahmaan_As-Sudais_192kbps',
      name: 'عبد الرحمن السديس',
      englishName: 'Abdurrahmaan Al Sudais',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Abu_Bakr_Ash-Shaatree_128kbps',
      name: 'أبو بكر الشاطري',
      englishName: 'Abu Bakr Ash-Shaatree',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Hani_Rifai_192kbps',
      name: 'هاني الرفاعي',
      englishName: 'Hani Rifai',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Husary_64kbps',
      name: 'محمود خليل الحصري',
      englishName: 'Mahmoud Khalil Al-Hussary',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Minshawy_Murattal_128kbps',
      name: 'المنشاوي (مرتل)',
      englishName: 'Minshawy (Murattal)',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Minshawy_Mujawwad_192kbps',
      name: 'المنشاوي (مجود)',
      englishName: 'Minshawy (Mujawwad)',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Mohammad_al_Tablaway_128kbps',
      name: 'محمد الطبلاوي',
      englishName: 'Mohammad Al Tablaway',
      format: 'audio',
      language: 'ar',
    ),
    Reciter(
      identifier: 'Saood_ash-Shuraym_128kbps',
      name: 'سعود الشريم',
      englishName: 'Saud Shuraim',
      format: 'audio',
      language: 'ar',
    ),
  ];
}

