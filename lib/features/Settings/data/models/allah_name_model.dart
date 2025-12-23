class AllahNameModel {
  final String name; // Arabic name
  final String transliteration; // English transliteration
  final int number;
  final String meaning; // English meaning

  AllahNameModel({
    required this.name,
    required this.transliteration,
    required this.number,
    required this.meaning,
  });

  factory AllahNameModel.fromJson(Map<String, dynamic> json) {
    return AllahNameModel(
      name: json['name'] ?? '',
      transliteration: json['transliteration'] ?? '',
      number: json['number'] ?? 0,
      meaning: json['en'] != null && json['en'] is Map
          ? (json['en'] as Map<String, dynamic>)['meaning'] ?? ''
          : '',
    );
  }

  // Getters for backward compatibility with existing widget
  String get title => name;
  String get enTitle => transliteration;
  String get traTitle => meaning;
}
