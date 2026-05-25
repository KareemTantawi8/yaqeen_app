class AllahNameModel {
  final int id;
  final String name;
  final String text;

  AllahNameModel({
    required this.id,
    required this.name,
    required this.text,
  });

  factory AllahNameModel.fromJson(Map<String, dynamic> json) {
    return AllahNameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      text: json['text'] ?? '',
    );
  }
}
