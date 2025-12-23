class IslamicEvent {
  final String title;
  final String date;
  final String description;
  final String link;

  IslamicEvent({
    required this.title,
    required this.date,
    required this.description,
    required this.link,
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      title: json['title'],
      date: json['date'],
      description: json['description'],
      link: json['link'],
    );
  }
}
