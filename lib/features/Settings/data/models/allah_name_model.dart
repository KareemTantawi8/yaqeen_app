class AllahNameModel {
  final String title;
  final String enTitle;
  final String traTitle;
  final String sound;

  AllahNameModel({
    required this.title,
    required this.enTitle,
    required this.traTitle,
    required this.sound,
  });

  factory AllahNameModel.fromJson(Map<String, dynamic> json) {
    return AllahNameModel(
      title: json['title'],
      enTitle: json['enTitle'],
      traTitle: json['traTitle'],
      sound: json['sound'],
    );
  }
}
