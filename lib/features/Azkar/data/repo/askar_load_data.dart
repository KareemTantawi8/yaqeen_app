import 'dart:convert';
import 'package:flutter/services.dart';

import '../model/askar_model.dart';

class AzkarService {
  static Future<List<Azkar>> loadAzkar() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/azkar_data_full.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Azkar.fromJson(json)).toList();
  }
}
