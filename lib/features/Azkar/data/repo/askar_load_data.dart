import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/services/network/api/api_endpoints.dart';
import '../model/adhkar_category_model.dart';

class AzkarService {
  static Future<List<AdhkarCategoryModel>> loadAzkar() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: '',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      final response = await dio.get(
        EndPoints.getAdhkarExternal,
        options: Options(
          responseType: ResponseType.plain, // Use plain to get raw string
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );
      
      if (response.statusCode == 200) {
        dynamic data;
        
        // Parse the response - it might be a String that needs to be decoded
        if (response.data is String) {
          data = jsonDecode(response.data as String);
        } else {
          data = response.data;
        }
        
        // Handle the response - it should be a List directly
        if (data is List) {
          return data
              .map((json) => AdhkarCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          final jsonList = data['data'] as List<dynamic>;
          return jsonList
              .map((json) => AdhkarCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}. Data: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}');
        }
      } else {
        throw Exception('Failed to load azkar: Status code ${response.statusCode}, ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      String errorMessage = 'Failed to load azkar';
      if (e.response != null) {
        errorMessage += ': ${e.response?.statusCode} - ${e.response?.statusMessage}';
        errorMessage += '\nData: ${e.response?.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage += ': Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage += ': Receive timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage += ': Connection error - ${e.message}';
      } else {
        errorMessage += ': ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Handle other errors
      throw Exception('Failed to load azkar: $e\nStackTrace: $stackTrace');
    }
  }
}
