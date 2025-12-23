import 'package:dio/dio.dart';
import '../../../../core/services/service_locator.dart';
import '../models/book_model.dart';

class BooksLoadData {
  static Future<BooksResponse> loadBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final dio = getIt<Dio>();
      // Replace :page and :limit with actual values
      final url = 'https://api3.islamhouse.com/v3/paV29H2gm56kvLPy/main/get-latest/month/showall/ar/ar/$page/$limit/json';
      
      final response = await dio.get(url);
      
      if (response.data is Map<String, dynamic>) {
        return BooksResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid API response format: expected Map');
      }
    } catch (e) {
      throw Exception('Failed to load books: $e');
    }
  }
}

