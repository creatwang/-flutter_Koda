import 'package:dio/dio.dart';

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
  }) {
    return _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
