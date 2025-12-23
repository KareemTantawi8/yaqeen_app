
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/surah_model.dart';

class QuranDataLoader {
  static Future<List<Surah>> loadSurahs() async {
    final jsonStr = await rootBundle.loadString('assets/data/surahs.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => Surah.fromJson(json)).toList();
  }
}
