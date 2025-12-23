class RadioModel {
  final String id;
  final String name;
  final String url;

  RadioModel({
    required this.id,
    required this.name,
    required this.url,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      id: json['Id']?.toString() ?? '',
      name: json['Name'] ?? '',
      url: json['URL'] ?? '',
    );
  }
}

class RadioResponse {
  final List<RadioModel> radios;

  RadioResponse({required this.radios});

  factory RadioResponse.fromJson(Map<String, dynamic> json) {
    final radiosList = json['Radios'] as List?;
    return RadioResponse(
      radios: radiosList != null
          ? radiosList.map((e) => RadioModel.fromJson(e)).toList()
          : [],
    );
  }
}

