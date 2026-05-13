import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith_model.dart';

class HadithBookInfo {
  final String arabicName;
  final String key;
  final String description;

  const HadithBookInfo({
    required this.arabicName,
    required this.key,
    required this.description,
  });
}

class HadithService {
  static const String _apiBase = 'https://api.hadith.gading.dev/books';

  // API IDs as returned by GET /books
  static const Map<String, String> _bookApiIds = {
    'bukhari':  'bukhari',
    'muslim':   'muslim',
    'abudawud': 'abu-daud',
    'tirmidhi': 'tirmidzi',
    'nasai':    'nasai',
    'ibnmajah': 'ibnu-majah',
  };

  // Confirmed available counts from GET /books
  static const Map<String, int> _bookMaxHadiths = {
    'bukhari':  6638,
    'muslim':   4930,
    'abudawud': 4419,
    'tirmidhi': 3625,
    'nasai':    5364,
    'ibnmajah': 4285,
  };

  static const Map<String, String> _bookArabicNames = {
    'bukhari':  'صحيح البخاري',
    'muslim':   'صحيح مسلم',
    'abudawud': 'سنن أبي داود',
    'tirmidhi': 'سنن الترمذي',
    'nasai':    'سنن النسائي',
    'ibnmajah': 'سنن ابن ماجه',
  };

  static const List<HadithBookInfo> books = [
    HadithBookInfo(arabicName: 'صحيح البخاري', key: 'bukhari',  description: '6638 حديث'),
    HadithBookInfo(arabicName: 'صحيح مسلم',    key: 'muslim',   description: '4930 حديث'),
    HadithBookInfo(arabicName: 'سنن أبي داود', key: 'abudawud', description: '4419 حديث'),
    HadithBookInfo(arabicName: 'سنن الترمذي',  key: 'tirmidhi', description: '3625 حديث'),
    HadithBookInfo(arabicName: 'سنن النسائي',  key: 'nasai',    description: '5364 حديث'),
    HadithBookInfo(arabicName: 'سنن ابن ماجه', key: 'ibnmajah', description: '4285 حديث'),
  ];

  static const String _dailyHadithKey  = 'daily_hadith_data';
  static const String _dailyDateKey    = 'daily_hadith_date';

  // ─────────────────────────────────────────────────────────────────────────────

  static Future<HadithModel> fetchRandomHadith({String book = 'bukhari'}) async {
    final maxCount = _bookMaxHadiths[book] ?? 6638;
    final number   = Random().nextInt(maxCount) + 1;
    final apiId    = _bookApiIds[book] ?? 'bukhari';
    final url      = '$_apiBase/$apiId/$number';

    debugPrint('HadithService: GET $url');

    try {
      final response = await http
          .get(Uri.parse(url),
              headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['error'] == true) {
        throw Exception('API error: ${json['message']}');
      }

      final data     = json['data']     as Map<String, dynamic>;
      final contents = data['contents'] as Map<String, dynamic>;
      final arabic   = (contents['arab'] as String?)?.trim() ?? '';

      if (arabic.isEmpty) throw Exception('Empty Arabic text returned');

      return HadithModel(
        bookName:    _bookArabicNames[book] ?? book,
        bookKey:     book,
        chapter:     '',
        arabicText:  arabic,
        englishText: '',
        refNo:       'H$number',
      );
    } catch (e) {
      debugPrint('HadithService error [$book #$number]: $e');
      rethrow;
    }
  }

  static Future<HadithModel> fetchHadithOfDay() async {
    final prefs   = await SharedPreferences.getInstance();
    final today   = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (prefs.getString(_dailyDateKey) == todayStr) {
      final saved = prefs.getString(_dailyHadithKey);
      if (saved != null) {
        try {
          return HadithModel.fromJson(jsonDecode(saved));
        } catch (_) {}
      }
    }

    final hadith = await fetchRandomHadith(book: 'bukhari');
    await prefs.setString(_dailyDateKey,    todayStr);
    await prefs.setString(_dailyHadithKey,  jsonEncode(hadith.toJson()));
    return hadith;
  }

  // Fetch [count] hadiths in parallel — much faster than sequential
  static Future<List<HadithModel>> fetchMultiple({
    String book  = 'bukhari',
    int    count = 8,
  }) async {
    final futures = List.generate(
      count,
      (_) => fetchRandomHadith(book: book).catchError((_) => null),
    );
    final results = await Future.wait(futures);
    return results.whereType<HadithModel>().toList();
  }
}
