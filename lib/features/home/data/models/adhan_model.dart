// Model for Adhan/Prayer Times by Location
class AdhanModel {
  final String location;
  final String date;
  final AdhanTimings timings;
  final LocationInfo? locationInfo;

  AdhanModel({
    required this.location,
    required this.date,
    required this.timings,
    this.locationInfo,
  });

  factory AdhanModel.fromJson(Map<String, dynamic> json) {
    return AdhanModel(
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      timings: AdhanTimings.fromJson(json['timings'] ?? {}),
      locationInfo: json['location_info'] != null
          ? LocationInfo.fromJson(json['location_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'date': date,
      'timings': timings.toJson(),
      'location_info': locationInfo?.toJson(),
    };
  }
}

class AdhanTimings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  AdhanTimings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory AdhanTimings.fromJson(Map<String, dynamic> json) {
    return AdhanTimings(
      fajr: json['fajr'] ?? json['Fajr'] ?? '00:00',
      sunrise: json['sunrise'] ?? json['Sunrise'] ?? '00:00',
      dhuhr: json['dhuhr'] ?? json['Dhuhr'] ?? '00:00',
      asr: json['asr'] ?? json['Asr'] ?? '00:00',
      maghrib: json['maghrib'] ?? json['Maghrib'] ?? '00:00',
      isha: json['isha'] ?? json['Isha'] ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  // Helper to get prayer time by name
  String getTimeByName(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
      case 'الفجر':
        return fajr;
      case 'dhuhr':
      case 'الظهر':
        return dhuhr;
      case 'asr':
      case 'العصر':
        return asr;
      case 'maghrib':
      case 'المغرب':
        return maghrib;
      case 'isha':
      case 'العشاء':
        return isha;
      default:
        return '00:00';
    }
  }
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;
  final String? timezone;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
    this.timezone,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      city: json['city'],
      country: json['country'],
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'timezone': timezone,
    };
  }
}

