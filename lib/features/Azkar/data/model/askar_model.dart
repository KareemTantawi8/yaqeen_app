class Azkar {
  final int id;
  final String title;
  final String content;

  Azkar({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Azkar.fromJson(Map<String, dynamic> json) {
    return Azkar(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }
}
