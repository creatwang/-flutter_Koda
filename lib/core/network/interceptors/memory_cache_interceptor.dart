import 'package:dio/dio.dart';

class MemoryCacheInterceptor extends Interceptor {
  MemoryCacheInterceptor({this.ttl = const Duration(minutes: 1)});

  final Duration ttl;
  final Map<String, _CacheEntry> _cache = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final useCache = options.method == 'GET' && options.extra['noCache'] != true;
    if (!useCache) return handler.next(options);

    final key = _cacheKey(options);
    final cached = _cache[key];
    if (cached == null) return handler.next(options);

    if (DateTime.now().difference(cached.timestamp) > ttl) {
      _cache.remove(key);
      return handler.next(options);
    }

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
    final canCache = options.method == 'GET' &&
        options.extra['noCache'] != true &&
        (response.statusCode ?? 500) < 400;
    if (canCache) {
      _cache[_cacheKey(options)] = _CacheEntry(
        timestamp: DateTime.now(),
        data: response.data,
      );
    }
    handler.next(response);
  }

  String _cacheKey(RequestOptions options) {
    return '${options.path}?${options.queryParameters}';
  }
}

class _CacheEntry {
  const _CacheEntry({required this.timestamp, required this.data});
  final DateTime timestamp;
  final dynamic data;
}
