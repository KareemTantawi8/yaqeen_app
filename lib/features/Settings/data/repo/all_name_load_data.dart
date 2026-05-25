import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/allah_name_model.dart';

class AllNamesLoadData {
  static Future<List<AllahNameModel>> loadFromAssets() async {
    final jsonString =
        await rootBundle.loadString('assets/data/Names_Of_Allah.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((e) => AllahNameModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
