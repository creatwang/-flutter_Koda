import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/core/storage/token_pair.dart';
import 'package:george_pick_mate/features/auth/api/auth_requests.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/auth/services/auth_session_snapshot_services.dart';

/// 注册并落盘会话（与登录成功后的持久化一致）。
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
        error: 'Invalid register response format',
      );
    }
    final userInfoBase = UserInfoBase.fromJson(data);
    final companyId = userInfoBase.companyId?.toInt();
    if (companyId == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid company_id in register response',
      );
    }
    await persistAuthenticatedUserSnapshot(userInfoBase);
    return ApiSuccess(
      TokenPair(token: userInfoBase.token.toString(), companyId: companyId),
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Register request failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
