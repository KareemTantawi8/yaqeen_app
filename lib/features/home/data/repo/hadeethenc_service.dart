import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadeethenc_models.dart';

class HadeethEncService {
  static const _base = 'https://hadeethenc.com/api/v1';

  // In-memory cache for the full categories list (used by search)
  static List<HadeethEncCategory>? _allCategoriesCache;

  static Future<List<HadeethEncCategory>> fetchRootCategories() async {
    final res = await http
        .get(Uri.parse('$_base/categories/roots/?language=ar'))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => HadeethEncCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('فشل تحميل الموضوعات (${res.statusCode})');
  }

  static Future<List<HadeethEncCategory>> fetchAllCategories({
    bool forceRefresh = false,
  }) async {
    if (_allCategoriesCache != null && !forceRefresh) {
      return _allCategoriesCache!;
    }
    final res = await http
        .get(Uri.parse('$_base/categories/list/?language=ar'))
        .timeout(const Duration(seconds: 25));
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      _allCategoriesCache = list
          .map((e) => HadeethEncCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      return _allCategoriesCache!;
    }
    throw Exception('فشل تحميل الفئات (${res.statusCode})');
  }

  static Future<HadeethEncPage> fetchHadiths(
    String categoryId, {
    int page = 1,
    int perPage = 15,
  }) async {
    final uri = Uri.parse(
      '$_base/hadeeths/list/?language=ar&category_id=$categoryId&page=$page&per_page=$perPage',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode == 200) {
      return HadeethEncPage.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('فشل تحميل الأحاديث (${res.statusCode})');
  }

  static Future<HadeethEncHadith> fetchHadithDetail(String id) async {
    final res = await http
        .get(Uri.parse('$_base/hadeeths/one/?language=ar&id=$id'))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode == 200) {
      return HadeethEncHadith.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('فشل تحميل الحديث (${res.statusCode})');
  }
}
