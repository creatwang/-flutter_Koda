import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/core/storage/token_pair.dart';
import 'package:george_pick_mate/features/auth/api/auth_requests.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/auth/services/auth_session_snapshot_services.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

typedef AuthRegisterService =
    Future<ApiResult<TokenPair>> Function({
      required String username,
      required String password,
      required String passwordConfirm,
    });

final authRegisterServiceProvider = Provider<AuthRegisterService>(
  (_) => authRegisterService,
);

Future<ApiResult<TokenPair>> authRegisterService({
  required String username,
  required String password,
  required String passwordConfirm,
}) async {
  try {
    final response = await requestAuthRegister(
      username: username,
      password: password,
      passwordConfirm: passwordConfirm,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidRegisterResponseFormat,
      );
    }
    final userInfoBase = UserInfoBase.fromApiEnvelope(data);
    final domain = userInfoBase.domain?.trim();
    if (domain == null || domain.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidDomainInRegisterResponse,
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
        e.message ?? appL10n.errorRegisterRequestFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
