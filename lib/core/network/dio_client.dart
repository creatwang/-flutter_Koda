import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/interceptors/memory_cache_interceptor.dart';
import 'package:george_pick_mate/core/network/interceptors/response_data_mode_interceptor.dart';

class DioClient {
  DioClient(this._dio);
  final Dio _dio;

  /// 清理当前 Dio 上挂载的全部内存缓存拦截器数据。
  void clearAllMemoryCaches() {
    for (final interceptor in _dio.interceptors) {
      if (interceptor is MemoryCacheInterceptor) {
        interceptor.clearAll();
      }
    }
  }

  /// 按前缀清理当前 Dio 的内存缓存，返回删除条数。
  int evictMemoryCacheByPrefix(String prefix) {
    var removed = 0;
    for (final interceptor in _dio.interceptors) {
      if (interceptor is MemoryCacheInterceptor) {
        removed += interceptor.evictByPrefix(prefix);
      }
    }
    return removed;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool simpleResponse = true,
  }) {
    final resolvedOptions = _resolveResponseModeOptions(
      options: options,
      simpleResponse: simpleResponse,
    );
    return _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: resolvedOptions,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool simpleResponse = true,
  }) {
    final resolvedOptions = _resolveResponseModeOptions(
      options: options,
      simpleResponse: simpleResponse,
    );
    return _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: resolvedOptions,
    );
  }

  Options _resolveResponseModeOptions({
    required Options? options,
    required bool simpleResponse,
  }) {
    final extra = <String, dynamic>{
      ...?options?.extra,
      ResponseDataModeInterceptor.responseDataModeExtraKey:
          simpleResponse ? ResponseDataMode.simple : ResponseDataMode.origin,
    };
    return (options ?? Options()).copyWith(extra: extra);
  }
}
