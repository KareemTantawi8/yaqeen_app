// Model for Full Quran Response (Text Format)
class QuranFullTextModel {
  final String mushaf;
  final int totalSurahs;
  final List<SurahTextModel> surahs;

  QuranFullTextModel({
    required this.mushaf,
    required this.totalSurahs,
    required this.surahs,
  });

  factory QuranFullTextModel.fromJson(Map<String, dynamic> json) {
    return QuranFullTextModel(
      mushaf: json['mushaf'] ?? 'uthmani',
      totalSurahs: json['total_surahs'] ?? 114,
      surahs: (json['surahs'] as List?)
              ?.map((surah) => SurahTextModel.fromJson(surah))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mushaf': mushaf,
      'total_surahs': totalSurahs,
      'surahs': surahs.map((s) => s.toJson()).toList(),
    };
  }
}

class SurahTextModel {
  final int surahId;
  final String name;
  final String? nameEnglish;
  final String? revelationType;
  final int? numberOfAyahs;
  final List<AyahTextModel> ayahs;

  SurahTextModel({
    required this.surahId,
    required this.name,
    this.nameEnglish,
    this.revelationType,
    this.numberOfAyahs,
    required this.ayahs,
  });

  factory SurahTextModel.fromJson(Map<String, dynamic> json) {
    return SurahTextModel(
      surahId: json['surah_id'] ?? json['number'] ?? 0,
      name: json['name'] ?? '',
      nameEnglish: json['name_english'] ?? json['englishName'],
      revelationType: json['revelation_type'] ?? json['revelationType'],
      numberOfAyahs: json['number_of_ayahs'] ?? json['numberOfAyahs'] ?? (json['ayahs'] as List?)?.length,
      ayahs: (json['ayahs'] as List?)
              ?.map((ayah) => AyahTextModel.fromJson(ayah))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_id': surahId,
      'name': name,
      'name_english': nameEnglish,
      'revelation_type': revelationType,
      'number_of_ayahs': numberOfAyahs,
      'ayahs': ayahs.map((a) => a.toJson()).toList(),
    };
  }
}

class AyahTextModel {
  final int ayahId;
  final String text;
  final int? page;
  final int? juz;

  AyahTextModel({
    required this.ayahId,
    required this.text,
    this.page,
    this.juz,
  });

  factory AyahTextModel.fromJson(Map<String, dynamic> json) {
    return AyahTextModel(
      ayahId: json['ayah_id'] ?? json['numberInSurah'] ?? json['number'] ?? 0,
      text: json['text'] ?? '',
      page: json['page'],
      juz: json['juz'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_id': ayahId,
      'text': text,
      'page': page,
      'juz': juz,
    };
  }
}

// Model for Full Quran Response (Image Format)
class QuranFullImageModel {
  final String type;
  final List<QuranPageModel> pages;

  QuranFullImageModel({
    required this.type,
    required this.pages,
  });

  factory QuranFullImageModel.fromJson(Map<String, dynamic> json) {
    return QuranFullImageModel(
      type: json['type'] ?? 'image',
      pages: (json['pages'] as List?)
              ?.map((page) => QuranPageModel.fromJson(page))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'pages': pages.map((p) => p.toJson()).toList(),
    };
  }
}

class QuranPageModel {
  final int page;
  final String imageUrl;

  QuranPageModel({
    required this.page,
    required this.imageUrl,
  });

  factory QuranPageModel.fromJson(Map<String, dynamic> json) {
    return QuranPageModel(
      page: json['page'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'image_url': imageUrl,
    };
  }
}

