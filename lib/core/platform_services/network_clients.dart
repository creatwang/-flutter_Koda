import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:george_pick_mate/core/config/env.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/network/interceptors/memory_cache_interceptor.dart';
import 'package:george_pick_mate/core/network/interceptors/request_trace_interceptor.dart';
import 'package:george_pick_mate/core/network/interceptors/response_data_mode_interceptor.dart';
import 'package:george_pick_mate/core/network/interceptors/retry_interceptor.dart';
import 'package:george_pick_mate/core/storage/secure_storage_service.dart';

import '../network/interceptors/auth_interceptor.dart';
import '../result/api_result.dart';
import '../storage/token_pair.dart';

typedef AuthRefreshService = Future<ApiResult<TokenPair>> Function(String refreshToken);
typedef AuthReadTokenService = Future<int?> Function();
typedef AuthClearTokenService = Future<void> Function();
final authReadTokenServiceProvider = Provider<AuthReadTokenService>(
  (ref) => secureStorageService.getCompanyId,
);
final authClearTokenServiceProvider = Provider<AuthClearTokenService>((ref) => authClearTokenService);

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

final SecureStorageService secureStorageService = SecureStorageService(const FlutterSecureStorage());

/// 清理全部 Dio 内存缓存（公开/鉴权客户端）。
void clearAllNetworkMemoryCaches() {
  publicDioClient.clearAllMemoryCaches();
  protectedDioClient.clearAllMemoryCaches();
}

/// 清理鉴权客户端中指定前缀的内存缓存。
int evictProtectedNetworkCacheByPrefix(String prefix) {
  return protectedDioClient.evictMemoryCacheByPrefix(prefix);
}

/// 开放客户端实例（无需登录的请求可复用）
final DioClient publicDioClient = DioClient(_buildPublicDio());

Dio _buildPublicDio({ResponseDataMode responseDataMode = ResponseDataMode.origin}) {
  final dio = Dio(buildBaseOptions());
  dio.interceptors.addAll([
    RequestTraceInterceptor(),
    ResponseDataModeInterceptor(responseDataMode),
    MemoryCacheInterceptor(ttl: const Duration(minutes: 2)),
    RetryInterceptor(dio),
  ]);
  return dio;
}

Future<void> authClearTokenService() => secureStorageService.clear();


/// 认证客户端实例
final DioClient protectedDioClient = DioClient(_buildProtectedDio());

Dio _buildProtectedDio({
  ResponseDataMode responseDataMode = ResponseDataMode.origin,
}) {
  final dio = Dio(buildBaseOptions());
  dio.interceptors.addAll([
    RequestTraceInterceptor(),
    ResponseDataModeInterceptor(responseDataMode),
    AuthInterceptor(secureStorageService),
    MemoryCacheInterceptor(ttl: const Duration(minutes: 2)),
    RetryInterceptor(dio),
  ]);

  return dio;
}
