class PrayerCompletionModel {
  final String prayerId;
  final String prayerName;
  final DateTime date;
  final bool isCompleted;
  final bool isQada; // if it's a missed prayer
  final DateTime? completionTime;

  PrayerCompletionModel({
    required this.prayerId,
    required this.prayerName,
    required this.date,
    required this.isCompleted,
    this.isQada = false,
    this.completionTime,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'prayerId': prayerId,
      'prayerName': prayerName,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'isQada': isQada,
      'completionTime': completionTime?.toIso8601String(),
    };
  }

  // Create from JSON
  factory PrayerCompletionModel.fromJson(Map<String, dynamic> json) {
    return PrayerCompletionModel(
      prayerId: json['prayerId'],
      prayerName: json['prayerName'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'],
      isQada: json['isQada'] ?? false,
      completionTime: json['completionTime'] != null
          ? DateTime.parse(json['completionTime'])
          : null,
    );
  }

  // Create a copy with modified fields
  PrayerCompletionModel copyWith({
    String? prayerId,
    String? prayerName,
    DateTime? date,
    bool? isCompleted,
    bool? isQada,
    DateTime? completionTime,
  }) {
    return PrayerCompletionModel(
      prayerId: prayerId ?? this.prayerId,
      prayerName: prayerName ?? this.prayerName,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      isQada: isQada ?? this.isQada,
      completionTime: completionTime ?? this.completionTime,
    );
  }
}

