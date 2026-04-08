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

final authLoginServiceProvider = Provider<AuthLoginService>((ref) => authLoginService);

Future<ApiResult<TokenPair>> authLoginService({ required String username, required String password, }) async {
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



