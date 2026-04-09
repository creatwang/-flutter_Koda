import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:groe_app_pad/core/config/env.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/network/interceptors/memory_cache_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/request_trace_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/retry_interceptor.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';

import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/refresh_token_interceptor.dart';
import '../result/api_result.dart';
import '../result/app_exception.dart';
import '../storage/token_pair.dart';

typedef AuthRefreshService = Future<ApiResult<TokenPair>> Function(String refreshToken);
typedef AuthReadTokenService = Future<TokenPair?> Function();
typedef AuthClearTokenService = Future<void> Function();
final authRefreshServiceProvider = Provider<AuthRefreshService>((ref) => authRefreshService);
final authReadTokenServiceProvider = Provider<AuthReadTokenService>((ref) => authReadTokenService);
final authClearTokenServiceProvider = Provider<AuthClearTokenService>((ref) => authClearTokenService);

Future<TokenPair?> authReadTokenService() => secureStorageService.readTokenPair();

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

Future<void> authClearTokenService() => secureStorageService.clear();
Future<ApiResult<TokenPair>> authRefreshService(String refreshToken) async {
  try {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final pair = TokenPair(
      accessToken: 'refreshed-access-$refreshToken',
      refreshToken: refreshToken,
    );
    await secureStorageService.saveTokenPair(pair);
    return ApiSuccess(pair);
  } catch (e) {
    return ApiFailure(AppException('Refresh token failed: $e'));
  }
}

/// 认证客户端实例
final DioClient protectedDioClient = DioClient(_buildProtectedDio());
Dio _buildProtectedDio() {
  final dio = Dio(buildBaseOptions());
  dio.interceptors.addAll([
    RequestTraceInterceptor(),
    AuthInterceptor(secureStorageService),
    MemoryCacheInterceptor(ttl: const Duration(minutes: 2)),
    RetryInterceptor(dio),
    RefreshTokenInterceptor(
      dio: dio,
      storageService: secureStorageService,
      onRefreshToken: (refreshToken) async {
        final result = await authRefreshService(refreshToken);
        return result.when(
          success: (pair) => pair,
          failure: (_) => null,
        );
      },
      onLogout: () async {
        await authClearTokenService();
      },
    ),
  ]);

  return dio;
}
