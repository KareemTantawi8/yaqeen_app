import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith_model.dart';

class HadithFavoriteService {
  static const String _key = 'favorite_hadiths_v1';

  static Future<List<HadithModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => HadithModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addFavorite(HadithModel hadith) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.any((h) => h.refNo == hadith.refNo)) {
      favorites.insert(0, hadith.copyWith(isFavorite: true));
      await prefs.setString(_key, jsonEncode(favorites.map((h) => h.toJson()).toList()));
    }
  }

  static Future<void> removeFavorite(String refNo) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((h) => h.refNo == refNo);
    await prefs.setString(_key, jsonEncode(favorites.map((h) => h.toJson()).toList()));
  }

  static Future<bool> isFavorite(String refNo) async {
    final favorites = await getFavorites();
    return favorites.any((h) => h.refNo == refNo);
  }

  // Returns true if added, false if removed
  static Future<bool> toggleFavorite(HadithModel hadith) async {
    final fav = await isFavorite(hadith.refNo);
    if (fav) {
      await removeFavorite(hadith.refNo);
      return false;
    } else {
      await addFavorite(hadith);
      return true;
    }
  }
}
