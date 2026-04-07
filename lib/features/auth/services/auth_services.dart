import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/network/interceptors/auth_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/memory_cache_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/request_trace_interceptor.dart';
import 'package:groe_app_pad/core/network/interceptors/retry_interceptor.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/core/services/core_services.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/api/auth_requests.dart';
import 'package:groe_app_pad/features/auth/models/auth_token_dto.dart';

typedef AuthLoginService = Future<ApiResult<TokenPair>> Function({
  required String username,
  required String password,
});
typedef AuthRefreshService = Future<ApiResult<TokenPair>> Function(String refreshToken);
typedef AuthReadTokenService = Future<TokenPair?> Function();
typedef AuthClearTokenService = Future<void> Function();

final authLoginServiceProvider = Provider<AuthLoginService>((ref) => authLoginService);
final authRefreshServiceProvider =
    Provider<AuthRefreshService>((ref) => authRefreshService);
final authReadTokenServiceProvider =
    Provider<AuthReadTokenService>((ref) => authReadTokenService);
final authClearTokenServiceProvider =
    Provider<AuthClearTokenService>((ref) => authClearTokenService);

Future<ApiResult<TokenPair>> authLoginService({
  required String username,
  required String password,
}) async {
  try {
    final response = await requestAuthLogin(
      username: username,
      password: password,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid login response format',
      );
    }
    final dto = AuthTokenDto(
      accessToken: data['token']?.toString() ?? 'demo-access-token',
      refreshToken: data['refreshToken']?.toString() ?? 'demo-refresh-token',
    );
    final pair = dto.toPair();
    await secureStorageService.saveTokenPair(pair);
    return ApiSuccess(pair);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Login request failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

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

final Dio protectedDio = _buildProtectedDio();
final DioClient protectedDioClient = DioClient(protectedDio);

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
