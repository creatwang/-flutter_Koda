import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/network/api_business_code.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/core/storage/token_pair.dart';
import 'package:george_pick_mate/features/auth/api/auth_requests.dart';
import 'package:george_pick_mate/features/auth/services/auth_session_snapshot_services.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

import '../models/user_info_bean.dart';

export 'package:george_pick_mate/core/platform_services/network_clients.dart'
    show
        AuthRefreshService,
        AuthClearTokenService,
        authClearTokenServiceProvider,
        authClearTokenService;

/// 登录用例：账号密码 → 持久化用户与站点 → [TokenPair]。
typedef AuthLoginService =
    Future<ApiResult<TokenPair>> Function({
      required String username,
      required String password,
    });

final authLoginServiceProvider = Provider<AuthLoginService>(
  (ref) => authLoginService,
);

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
        error: message ?? appL10n.errorLogoutFailed,
        message: message ?? appL10n.errorLogoutFailed,
      );
    }
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorLogoutRequestFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

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

/// 执行登录并写入 `userInfoBase`、站点 domain，同步站点信息。
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
        error: appL10n.errorInvalidLoginResponseFormat,
      );
    }
    if (!isApiBusinessSuccessCode(data['code'])) {
      final raw = data['message'] ?? data['msg'] ?? data['error'];
      final message = raw is String && raw.trim().isNotEmpty
          ? raw.trim()
          : appL10n.errorLoginRequestFailed;
      return ApiFailure(AppException(message));
    }
    final userInfoBase = UserInfoBase.fromApiEnvelope(data);
    final domain = userInfoBase.domain?.trim();
    if (domain == null || domain.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidDomainInLoginResponse,
      );
    }
    await persistAuthenticatedUserSnapshot(userInfoBase);
    return ApiSuccess(
      TokenPair(
        token: userInfoBase.token.toString(),
        storeHost: normalizeStoreHost(domain),
      ),
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorLoginRequestFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
