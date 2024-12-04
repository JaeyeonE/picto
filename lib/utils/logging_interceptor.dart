// lib/utils/logging_interceptor.dart

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('=== HTTP Request ===');
    print('URL: ${options.baseUrl}${options.path}');
    print('Method: ${options.method}');
    print('Headers: ${options.headers}');
    print('Body: ${options.data}');
    print('==================');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('=== HTTP Response ===');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.data}');
    print('===================');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('=== HTTP Error ===');
    print('Status Code: ${err.response?.statusCode}');
    print('Response: ${err.response?.data}');
    print('Message: ${err.message}');
    print('Error Type: ${err.type}');
    print('================');
    return super.onError(err, handler);
  }
}