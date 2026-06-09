class HadithModel {
  final String bookName;
  final String bookKey;
  final String chapter;
  final String arabicText;
  final String englishText;
  final String narrator;
  final String grade;
  final String refNo;
  final String tafsir;
  bool isFavorite;

  HadithModel({
    required this.bookName,
    this.bookKey = 'bukhari',
    required this.chapter,
    required this.arabicText,
    required this.englishText,
    this.narrator = '',
    this.grade = '',
    required this.refNo,
    this.tafsir = '',
    this.isFavorite = false,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      bookName: json['book_name'] ?? 'صحيح البخاري',
      bookKey: json['book_key'] ?? 'bukhari',
      chapter: json['chapterName'] ?? json['header'] ?? '',
      arabicText: json['hadith_arabic'] ?? '',
      englishText: json['hadith_english'] ?? '',
      narrator: json['narrator'] ?? '',
      grade: json['grade'] ?? '',
      refNo: json['refno']?.toString() ?? '',
      tafsir: json['tafsir'] ?? '',
      isFavorite: json['isFavorite'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_name': bookName,
      'book_key': bookKey,
      'chapterName': chapter,
      'hadith_arabic': arabicText,
      'hadith_english': englishText,
      'narrator': narrator,
      'grade': grade,
      'refno': refNo,
      'tafsir': tafsir,
      'isFavorite': isFavorite,
    };
  }

  HadithModel copyWith({
    String? bookName,
    String? bookKey,
    String? chapter,
    String? arabicText,
    String? englishText,
    String? narrator,
    String? grade,
    String? refNo,
    String? tafsir,
    bool? isFavorite,
  }) {
    return HadithModel(
      bookName: bookName ?? this.bookName,
      bookKey: bookKey ?? this.bookKey,
      chapter: chapter ?? this.chapter,
      arabicText: arabicText ?? this.arabicText,
      englishText: englishText ?? this.englishText,
      narrator: narrator ?? this.narrator,
      grade: grade ?? this.grade,
      refNo: refNo ?? this.refNo,
      tafsir: tafsir ?? this.tafsir,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
