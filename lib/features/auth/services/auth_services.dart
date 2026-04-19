import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/core/storage/token_pair.dart';
import 'package:groe_app_pad/features/auth/api/auth_requests.dart';
import 'package:groe_app_pad/features/auth/services/auth_session_snapshot_services.dart';

import '../models/user_info_bean.dart';

export 'package:groe_app_pad/core/platform_services/network_clients.dart'
    show
        AuthRefreshService,
        AuthReadTokenService,
        AuthClearTokenService,
        authReadTokenServiceProvider,
        authClearTokenServiceProvider,
        authClearTokenService;

/// 登录用例：账号密码 → 持久化用户与站点 → [TokenPair]。
typedef AuthLoginService =
    Future<ApiResult<TokenPair>> Function({
      required String username,
      required String password,
    });

/// 暴露给 [Provider] 的默认登录实现。
final authLoginServiceProvider = Provider<AuthLoginService>(
  (ref) => authLoginService,
);

/// 调用 `POST /store/user/logout`；成功返回 [ApiSuccess]，否则 [ApiFailure]。
Future<ApiResult<void>> logoutStoreUserService({DioClient? client}) async {
  try {
    final response = await requestAuthLogout(client: client);
    final data = response.data;
    if (!_isLogoutResponseSuccess(data)) {
      final message = data is Map<String, dynamic>
          ? data['message']?.toString()
          : null;
      throw DioException(
        requestOptions: response.requestOptions,
        error: message ?? 'Logout failed',
        message: message ?? 'Logout failed',
      );
    }
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Logout request failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 登出接口约定包：
/// `{ "code": 0, "message": "ok", "type": "success", "result": true }`
bool _isLogoutResponseSuccess(dynamic data) {
  if (data == null || data == '') return true;
  if (data == false || data == 'false') return false;
  if (data == true ||
      data == 1 ||
      data == '1' ||
      data?.toString().toLowerCase() == 'true') {
    return true;
  }
  if (data == 0 || data == '0') return false;
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    final codeInt = _parseIntLoose(map['code']);
    if (codeInt != null && codeInt != 0) return false;

    if (map.containsKey('result')) {
      final result = map['result'];
      if (result == false ||
          result == 0 ||
          result?.toString().toLowerCase() == 'false' ||
          result?.toString() == '0') {
        return false;
      }
      if (result == true ||
          result == 1 ||
          result?.toString() == '1' ||
          result?.toString().toLowerCase() == 'true') {
        return true;
      }
    }
    if (codeInt == 0) return true;
    if (!map.containsKey('code') && !map.containsKey('result')) {
      return true;
    }
    return false;
  }
  if (data is String) {
    final lower = data.trim().toLowerCase();
    if (lower == 'false' || lower == '0') return false;
    return lower.isNotEmpty;
  }
  return false;
}

int? _parseIntLoose(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

/// 执行登录并写入 `userInfoBase`、`companyId`、`tokenMap`，同步站点信息。
///
/// [username] / [password]：登录凭证。
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
    await persistAuthenticatedUserSnapshot(userInfoBase);
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
