class AdhkarItemModel {
  final int id;
  final String text;
  final int count;
  final String? audio;
  final String? filename;

  AdhkarItemModel({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.filename,
  });

  factory AdhkarItemModel.fromJson(Map<String, dynamic> json) {
    return AdhkarItemModel(
      id: json['id'] as int,
      text: json['text'] as String,
      count: json['count'] as int? ?? 1,
      audio: json['audio'] as String?,
      filename: json['filename'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'count': count,
      'audio': audio,
      'filename': filename,
    };
  }
}

