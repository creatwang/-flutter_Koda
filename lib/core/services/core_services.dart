import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:groe_app_pad/core/config/env.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/network/interceptors/memory_cache_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/request_trace_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/retry_interceptor.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';

/// 基础网络配置
BaseOptions buildBaseOptions() {
  return BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: Env.connectTimeout,
    receiveTimeout: Env.receiveTimeout,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
  );
}
final FlutterSecureStorage appSecureStorage = const FlutterSecureStorage();
final SecureStorageService secureStorageService = SecureStorageService(appSecureStorage);

/// 开放客户端实例（无需登录的请求可复用）
final DioClient publicDioClient = DioClient(_buildPublicDio());

Dio _buildPublicDio() {
  final dio = Dio(buildBaseOptions());
  dio.interceptors.addAll([
    RequestTraceInterceptor(),
    MemoryCacheInterceptor(ttl: const Duration(minutes: 2)),
    RetryInterceptor(dio),
  ]);
  return dio;
}