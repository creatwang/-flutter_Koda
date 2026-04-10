import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/interceptors/response_data_mode_interceptor.dart';

class DioClient {
  DioClient(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool simpleResponse = false,
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
