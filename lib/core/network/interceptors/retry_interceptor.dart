import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retries = (options.extra['retries'] as int?) ?? 0;

    final retryable = _isRetryable(err) && retries < maxRetries;
    if (!retryable) return handler.next(err);

    options.extra['retries'] = retries + 1;
    await Future<void>.delayed(Duration(milliseconds: 300 * (retries + 1)));
    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final networkError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
    final serverError = statusCode >= 500;
    final idempotent = err.requestOptions.method == 'GET';
    return idempotent && (networkError || serverError);
  }
}
