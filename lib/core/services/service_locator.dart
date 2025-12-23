import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'network/api/api_consumer.dart';
import 'network/api/dio_consumer.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Dio
  getIt.registerLazySingleton<Dio>(() => Dio());
  
  // ApiConsumer
  getIt.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(dio: getIt<Dio>()),
  );
}

