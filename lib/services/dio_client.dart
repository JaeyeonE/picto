import 'package:dio/dio.dart';

class DioClient {
  static Dio getInstance(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Request Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('ERROR[${error.response?.statusCode}] => ${error.message}');
        return handler.next(error);
      },
    ));

    return dio;
  }
}