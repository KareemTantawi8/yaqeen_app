class PrayerTimingsModel {
  final Timings timings;
  final DateInfo date;
  final Meta meta;

  PrayerTimingsModel({
    required this.timings,
    required this.date,
    required this.meta,
  });

  factory PrayerTimingsModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimingsModel(
      timings: Timings.fromJson(json['timings'] as Map<String, dynamic>),
      date: DateInfo.fromJson(json['date'] as Map<String, dynamic>),
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timings': timings.toJson(),
      'date': date.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class Timings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final String firstthird;
  final String lastthird;

  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.firstthird,
    required this.lastthird,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      fajr: json['Fajr'] as String,
      sunrise: json['Sunrise'] as String,
      dhuhr: json['Dhuhr'] as String,
      asr: json['Asr'] as String,
      sunset: json['Sunset'] as String,
      maghrib: json['Maghrib'] as String,
      isha: json['Isha'] as String,
      imsak: json['Imsak'] as String,
      midnight: json['Midnight'] as String,
      firstthird: json['Firstthird'] as String,
      lastthird: json['Lastthird'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Sunset': sunset,
      'Maghrib': maghrib,
      'Isha': isha,
      'Imsak': imsak,
      'Midnight': midnight,
      'Firstthird': firstthird,
      'Lastthird': lastthird,
    };
  }

  // Helper method to get prayer times as a map
  Map<String, String> getPrayerTimes() {
    return {
      'الفجر': fajr,
      'الشروق': sunrise,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };
  }
}

class DateInfo {
  final String readable;
  final String timestamp;
  final HijriDate hijri;
  final GregorianDate gregorian;

  DateInfo({
    required this.readable,
    required this.timestamp,
    required this.hijri,
    required this.gregorian,
  });

  factory DateInfo.fromJson(Map<String, dynamic> json) {
    return DateInfo(
      readable: json['readable'] as String,
      timestamp: json['timestamp'] as String,
      hijri: HijriDate.fromJson(json['hijri'] as Map<String, dynamic>),
      gregorian: GregorianDate.fromJson(json['gregorian'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'readable': readable,
      'timestamp': timestamp,
      'hijri': hijri.toJson(),
      'gregorian': gregorian.toJson(),
    };
  }
}

class HijriDate {
  final String date;
  final String format;
  final String day;
  final HijriWeekday weekday;
  final HijriMonth month;
  final String year;

  HijriDate({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'] as String,
      format: json['format'] as String,
      day: json['day'] as String,
      weekday: HijriWeekday.fromJson(json['weekday'] as Map<String, dynamic>),
      month: HijriMonth.fromJson(json['month'] as Map<String, dynamic>),
      year: json['year'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'format': format,
      'day': day,
      'weekday': weekday.toJson(),
      'month': month.toJson(),
      'year': year,
    };
  }

  // Helper method to get formatted Hijri date
  String getFormattedDate() {
    return '$day ${month.ar} $year هـ';
  }
}

class HijriWeekday {
  final String en;
  final String ar;

  HijriWeekday({
    required this.en,
    required this.ar,
  });

  factory HijriWeekday.fromJson(Map<String, dynamic> json) {
    return HijriWeekday(
      en: json['en'] as String,
      ar: json['ar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ar': ar,
    };
  }
}

class HijriMonth {
  final int number;
  final String en;
  final String ar;
  final int days;

  HijriMonth({
    required this.number,
    required this.en,
    required this.ar,
    required this.days,
  });

  factory HijriMonth.fromJson(Map<String, dynamic> json) {
    return HijriMonth(
      number: json['number'] as int,
      en: json['en'] as String,
      ar: json['ar'] as String,
      days: json['days'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'en': en,
      'ar': ar,
      'days': days,
    };
  }
}

class GregorianDate {
  final String date;
  final String format;
  final String day;
  final GregorianWeekday weekday;
  final GregorianMonth month;
  final String year;

  GregorianDate({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'] as String,
      format: json['format'] as String,
      day: json['day'] as String,
      weekday: GregorianWeekday.fromJson(json['weekday'] as Map<String, dynamic>),
      month: GregorianMonth.fromJson(json['month'] as Map<String, dynamic>),
      year: json['year'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'format': format,
      'day': day,
      'weekday': weekday.toJson(),
      'month': month.toJson(),
      'year': year,
    };
  }
}

class GregorianWeekday {
  final String en;

  GregorianWeekday({
    required this.en,
  });

  factory GregorianWeekday.fromJson(Map<String, dynamic> json) {
    return GregorianWeekday(
      en: json['en'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
    };
  }
}

class GregorianMonth {
  final int number;
  final String en;

  GregorianMonth({
    required this.number,
    required this.en,
  });

  factory GregorianMonth.fromJson(Map<String, dynamic> json) {
    return GregorianMonth(
      number: json['number'] as int,
      en: json['en'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'en': en,
    };
  }
}

class Meta {
  final double latitude;
  final double longitude;
  final String timezone;

  Meta({
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }
}

