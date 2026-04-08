import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:groe_app_pad/core/config/env.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/network/interceptors/memory_cache_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/request_trace_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/retry_interceptor.dart';
import 'package:groe_app_pad/core/storage/secure_storage_service.dart';

import '../../features/auth/services/auth_services.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/refresh_token_interceptor.dart';
import '../result/api_result.dart';
import '../result/app_exception.dart';
import '../storage/token_pair.dart';

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

final Dio publicDio = _buildPublicDio();
final DioClient publicDioClient = DioClient(publicDio);

Dio _buildPublicDio() {
  final dio = Dio(buildBaseOptions());
  dio.interceptors.addAll([
    RequestTraceInterceptor(),
    MemoryCacheInterceptor(ttl: const Duration(minutes: 2)),
    RetryInterceptor(dio),
  ]);
  return dio;
}


final authRefreshServiceProvider = Provider<AuthRefreshService>((ref) => authRefreshService);
final authReadTokenServiceProvider = Provider<AuthReadTokenService>((ref) => authReadTokenService);
final authClearTokenServiceProvider = Provider<AuthClearTokenService>((ref) => authClearTokenService);

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

Future<TokenPair?> authReadTokenService() => secureStorageService.readTokenPair();
Future<void> authClearTokenService() => secureStorageService.clear();

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

final Dio protectedDio = _buildProtectedDio();
final DioClient protectedDioClient = DioClient(protectedDio);