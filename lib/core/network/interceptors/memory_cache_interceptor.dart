import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:groe_app_pad/core/config/env.dart';

/// 内存缓存拦截器（仅 GET）：
/// - 请求阶段：命中缓存则直接返回，不再发网络请求
/// - 请求带 `extra['noCache'] == true` 时跳过读缓存，但仍发网络请求
/// - 响应阶段：成功 GET 一律写入/覆盖缓存（含 noCache），避免「刷新/删购后」
///   仍留下删改前的旧条目，导致后续默认可缓存请求读到脏数据
/// - 通过 ttl 控制过期时间，避免脏数据长期驻留
class MemoryCacheInterceptor extends Interceptor {
  MemoryCacheInterceptor({this.ttl = const Duration(minutes: 1)});

  final Duration ttl;
  final Map<String, _CacheEntry> _cache = {};

  /// 清空当前拦截器持有的全部内存缓存。
  void clearAll() => _cache.clear();

  /// 删除指定完整缓存键，返回是否存在并删除成功。
  bool evictKey(String key) => _cache.remove(key) != null;

  /// 删除指定前缀命中的缓存键，返回删除数量。
  int evictByPrefix(String prefix) {
    final matchedKeys = _cache.keys.where((key) => key.startsWith(prefix));
    final keysToRemove = matchedKeys.toList(growable: false);
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    return keysToRemove.length;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = '${options.extra['requestId'] ?? '-'}';
    // 只有 GET 且未显式 noCache 时才尝试缓存。
    final useCache = options.method == 'GET' && options.extra['noCache'] != true;
    if (!useCache) {
      _log('[NET][CACHE][$requestId] bypass ${options.method} ${options.path}');
      return handler.next(options);
    }

    final key = _cacheKey(options);
    final cached = _cache[key];
    if (cached == null) {
      _log('[NET][CACHE][$requestId] miss key=$key');
      return handler.next(options);
    }

    if (DateTime.now().difference(cached.timestamp) > ttl) {
      // 过期后删除并继续走真实请求。
      _cache.remove(key);
      _log('[NET][CACHE][$requestId] expired key=$key');
      return handler.next(options);
    }

    // 命中缓存：直接 short-circuit 返回 Response。
    _log('[NET][CACHE][$requestId] hit key=$key');
    handler.resolve(
      Response(
        requestOptions: options,
        data: cached.data,
        statusCode: 200,
        extra: {'fromCache': true},
      ),
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final requestId = '${options.extra['requestId'] ?? '-'}';
    // 成功 GET 一律落盘：默认可缓存请求与带 noCache 的刷新请求共用同一 key，
    // 刷新后必须覆盖旧缓存，否则删除/加购后再走未带 noCache 的 GET 会读到旧列表。
    final isGet = options.method == 'GET';
    final isSuccess = (response.statusCode ?? 500) < 400;
    if (isGet && isSuccess) {
      final key = _cacheKey(options);
      _cache[key] = _CacheEntry(
        timestamp: DateTime.now(),
        data: response.data,
      );
      final afterBypass = options.extra['noCache'] == true;
      _log(
        '[NET][CACHE][$requestId] save key=$key'
        '${afterBypass ? ' (post-bypass)' : ''}',
      );
    } else {
      _log(
        '[NET][CACHE][$requestId] skip save ${options.method} ${options.path}',
      );
    }
    handler.next(response);
  }

  String _cacheKey(RequestOptions options) {
    return '${options.path}?${options.queryParameters}';
  }

  // 统一日志出口：仅在 Debug 且开启 netTrace 时打印。
  void _log(String message) {
    if (kDebugMode && Env.netTraceEnabled) debugPrint(message);
  }
}

class _CacheEntry {
  const _CacheEntry({required this.timestamp, required this.data});
  final DateTime timestamp;
  final dynamic data;
}
