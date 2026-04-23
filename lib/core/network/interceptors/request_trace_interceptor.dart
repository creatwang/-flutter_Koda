import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:george_pick_mate/core/config/env.dart';

/// 请求链路追踪拦截器：
/// - 给每次请求生成唯一 requestId，便于前后端联调定位
/// - 记录请求开始时间，并在响应/错误阶段计算耗时
/// - 统一输出请求、响应、异常日志
/// - 对敏感请求头做脱敏，避免日志泄露凭证
/// - 仅在 Debug 模式打印日志，降低生产环境噪音
class RequestTraceInterceptor extends Interceptor {
  final _random = Random();
  static const _requestIdKey = 'requestId';
  static const _startAtKey = 'traceStartAtMs';

  static const _sensitiveHeaderKeys = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 生成请求 ID（时间戳 + 随机数），用来串联同一条请求链路。
    final requestId =
        '${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(99999)}';
    // 透传到后端，便于后端日志和客户端日志关联。
    options.headers['X-Request-Id'] = requestId;
    // 保存到 extra，供 onResponse/onError 读取。
    options.extra[_requestIdKey] = requestId;
    // 记录请求起始时间，用于计算总耗时。
    options.extra[_startAtKey] = DateTime.now().millisecondsSinceEpoch;
    _log(
      '[NET][TRACE][$requestId][REQ] ${options.method} ${options.path}'
      ' headers=${_safeHeaders(options.headers)}'
      ' query=${options.queryParameters}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra[_requestIdKey];
    // 计算本次请求耗时（毫秒）。
    final elapsedMs = _elapsedMs(response.requestOptions);
    // 与缓存拦截器协作：命中缓存时会在日志标识 (cache)。
    final fromCache = response.requestOptions.extra['fromCache'] == true;
    _log(
      '[NET][TRACE][$requestId][RES] ${response.statusCode} ${response.requestOptions.path}'
      ' (${elapsedMs}ms)'
      '${fromCache ? ' (cache)' : ''}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra[_requestIdKey];
    // 异常也打印同一个 requestId，方便快速定位失败请求。
    final elapsedMs = _elapsedMs(err.requestOptions);
    _log(
      '[NET][TRACE][$requestId][ERR] ${err.type} ${err.requestOptions.method} ${err.requestOptions.path}'
      ' (${elapsedMs}ms)'
      ' message=${err.message}',
    );
    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final startAt = options.extra[_startAtKey];
    if (startAt is! int) return -1;
    final elapsed = DateTime.now().millisecondsSinceEpoch - startAt;
    return elapsed < 0 ? 0 : elapsed;
  }

  // 将敏感 header 脱敏，避免 token/cookie 出现在日志中。
  Map<String, String> _safeHeaders(Map<String, dynamic> headers) {
    final safe = <String, String>{};
    headers.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      safe[key] = _sensitiveHeaderKeys.contains(lowerKey) ? '***' : '$value';
    });
    return safe;
  }

  // 统一日志出口：当前只在 debug 模式输出。
  void _log(String message) {
    if (kDebugMode && Env.netTraceEnabled) debugPrint(message);
  }
}
