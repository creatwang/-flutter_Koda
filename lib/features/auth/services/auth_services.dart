import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/api/auth_requests.dart';
import 'package:groe_app_pad/features/auth/services/site_info_services.dart';

import '../models/user_info_bean.dart';

export 'package:groe_app_pad/core/platform_services/network_clients.dart'
    show
        AuthRefreshService,
        AuthReadTokenService,
        AuthClearTokenService,
        authReadTokenServiceProvider,
        authClearTokenServiceProvider,
        authClearTokenService;

typedef AuthLoginService =
    Future<ApiResult<TokenPair>> Function({
      required String username,
      required String password,
    });

final authLoginServiceProvider = Provider<AuthLoginService>(
  (ref) => authLoginService,
);

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
    final userInfoBase = UserInfoBase.fromJson(data);
    final companyId = userInfoBase.companyId?.toInt();
    if (companyId == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid company_id in login response',
      );
    }
    await secureStorageService.saveUserInfoBase(userInfoBase);
    await secureStorageService.saveCompanyId(companyId);
    await secureStorageService.saveTokenMap(
      companyId,
      userInfoBase.token.toString(),
    );
    await syncSiteInfoToLocal(companyId: companyId);
    return ApiSuccess(
      TokenPair(token: userInfoBase.token.toString(), companyId: companyId),
    );
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
