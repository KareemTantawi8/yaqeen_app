class HadithModel {
  final String bookName;
  final String chapter;
  final String arabicText;
  final String englishText;
  final String refNo;

  HadithModel({
    required this.bookName,
    required this.chapter,
    required this.arabicText,
    required this.englishText,
    required this.refNo,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      bookName: json['book_name'] ?? 'صحيح البخاري',
      chapter: json['chapterName'] ?? '',
      arabicText: json['hadith_arabic'] ?? '',
      englishText: json['hadith_english'] ?? '',
      refNo: json['refno']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_name': bookName,
      'chapterName': chapter,
      'hadith_arabic': arabicText,
      'hadith_english': englishText,
      'refno': refNo,
    };
  }
}
