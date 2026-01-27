import 'package:dio/dio.dart';
import 'package:map/interceptors/interceptors.dart';

class DioClient {
  static final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(ApiInterceptors());
  // dio.options.baseUrl = 'https://jsonplaceholder.typicode.com/';
  // dio.options.connectTimeout = 5000 as Duration?; // 5 seconds
  // dio.interceptors.add(ApiInterceptors());

  // Implementation of the Client class
}
