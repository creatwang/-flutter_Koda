import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:george_pick_mate/core/config/env.dart';

/// 网络重试拦截器（仅幂等 GET）：
/// - 对网络错误/5xx 做有限重试
/// - 使用简单线性退避（300ms * 重试次数）
/// - 超过上限后透传原异常
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final requestId = '${options.extra['requestId'] ?? '-'}';
    final retries = (options.extra['retries'] as int?) ?? 0;

    // 不满足重试条件则直接结束。
    final retryable = _isRetryable(err) && retries < maxRetries;
    if (!retryable) {
      _log('[NET][RETRY][$requestId] skip retries=$retries reason=${err.type}');
      return handler.next(err);
    }

    // 标记重试次数，供后续日志与限制判断。
    options.extra['retries'] = retries + 1;
    final delayMs = 300 * (retries + 1);
    _log(
      '[NET][RETRY][$requestId] attempt=${retries + 1}/$maxRetries '
      '${options.method} ${options.path} delay=${delayMs}ms',
    );
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    try {
      final response = await _dio.fetch<dynamic>(options);
      _log('[NET][RETRY][$requestId] success on attempt=${retries + 1}');
      handler.resolve(response);
    } on DioException catch (e) {
      _log('[NET][RETRY][$requestId] failed on attempt=${retries + 1} type=${e.type}');
      handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final noRetry = err.requestOptions.extra['noRetry'] == true;
    if (noRetry) return false;
    // 可重试的网络层错误。
    final networkError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
    // 服务端 5xx 错误允许重试。
    final serverError = statusCode >= 500;
    // 仅重试幂等请求，避免 POST/PUT 重放副作用。
    final idempotent = err.requestOptions.method == 'GET';
    return idempotent && (networkError || serverError);
  }

  // 统一日志出口：仅在 Debug 且开启 netTrace 时打印。
  void _log(String message) {
    if (kDebugMode && Env.netTraceEnabled) debugPrint(message);
  }
}
