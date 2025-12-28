// Model for Full Surah with Audio
class SurahFullModel {
  final int surahId;
  final String name;
  final String? nameEnglish;
  final String? reciter;
  final String? audioUrl;
  final List<AyahWithAudioModel> ayahs;

  SurahFullModel({
    required this.surahId,
    required this.name,
    this.nameEnglish,
    this.reciter,
    this.audioUrl,
    required this.ayahs,
  });

  factory SurahFullModel.fromJson(Map<String, dynamic> json) {
    return SurahFullModel(
      surahId: json['surah_id'] ?? 0,
      name: json['name'] ?? '',
      nameEnglish: json['name_english'],
      reciter: json['reciter'],
      audioUrl: json['audio_url'],
      ayahs: (json['ayahs'] as List?)
              ?.map((ayah) => AyahWithAudioModel.fromJson(ayah))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_id': surahId,
      'name': name,
      'name_english': nameEnglish,
      'reciter': reciter,
      'audio_url': audioUrl,
      'ayahs': ayahs.map((a) => a.toJson()).toList(),
    };
  }
}

class AyahWithAudioModel {
  final int ayahId;
  final String text;
  final String? audio;
  final int? page;

  AyahWithAudioModel({
    required this.ayahId,
    required this.text,
    this.audio,
    this.page,
  });

  factory AyahWithAudioModel.fromJson(Map<String, dynamic> json) {
    return AyahWithAudioModel(
      ayahId: json['ayah_id'] ?? 0,
      text: json['text'] ?? '',
      audio: json['audio'],
      page: json['page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_id': ayahId,
      'text': text,
      'audio': audio,
      'page': page,
    };
  }
}

// Available Reciters Model
class ReciterModel {
  final String id;
  final String name;
  final String nameArabic;
  final String? image;

  ReciterModel({
    required this.id,
    required this.name,
    required this.nameArabic,
    this.image,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameArabic: json['name_arabic'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_arabic': nameArabic,
      'image': image,
    };
  }
}

