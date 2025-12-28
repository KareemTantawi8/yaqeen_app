class PrayerStatsModel {
  final int totalPrayers;
  final int completedPrayers;
  final int missedPrayers;
  final int currentStreak;
  final int longestStreak;
  final double completionPercentage;
  final Map<String, int> prayerWiseStats;

  PrayerStatsModel({
    required this.totalPrayers,
    required this.completedPrayers,
    required this.missedPrayers,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionPercentage,
    required this.prayerWiseStats,
  });

  // Create from JSON
  factory PrayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PrayerStatsModel(
      totalPrayers: json['totalPrayers'] ?? 0,
      completedPrayers: json['completedPrayers'] ?? 0,
      missedPrayers: json['missedPrayers'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      completionPercentage: (json['completionPercentage'] ?? 0.0).toDouble(),
      prayerWiseStats: Map<String, int>.from(json['prayerWiseStats'] ?? {}),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalPrayers': totalPrayers,
      'completedPrayers': completedPrayers,
      'missedPrayers': missedPrayers,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completionPercentage': completionPercentage,
      'prayerWiseStats': prayerWiseStats,
    };
  }

  // Create empty stats
  factory PrayerStatsModel.empty() {
    return PrayerStatsModel(
      totalPrayers: 0,
      completedPrayers: 0,
      missedPrayers: 0,
      currentStreak: 0,
      longestStreak: 0,
      completionPercentage: 0.0,
      prayerWiseStats: {
        'الفجر': 0,
        'الظهر': 0,
        'العصر': 0,
        'المغرب': 0,
        'العشاء': 0,
      },
    );
  }
}

