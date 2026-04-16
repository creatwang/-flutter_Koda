import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/profile/api/profile_requests.dart';
import 'package:groe_app_pad/features/profile/models/user_profile_info_dto.dart';

Future<ApiResult<UserProfileInfoDto>> fetchUserInfoService() async {
  try {
    final response = await requestUserInfo();
    final payload = _resolveResultMap(response.data);
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid user info response format',
      );
    }
    return ApiSuccess(UserProfileInfoDto.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch user info failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<void>> updateUserInfoService({
  required String name,
  required String oldPassword,
  required String newPassword,
  required String conPassword,
}) async {
  try {
    final response = await requestUpdateUserInfo(
      name: name,
      oldPassword: oldPassword,
      newPassword: newPassword,
      conPassword: conPassword,
    );
    final data = response.data;
    if (_isUpdateSuccess(data)) {
      return const ApiSuccess(null);
    }
    final failureMessage =
        data is Map<String, dynamic> ? data['message']?.toString() : null;
    throw DioException(
      requestOptions: response.requestOptions,
      error: failureMessage ?? 'Update user info failed',
      message: failureMessage ?? 'Update user info failed',
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Update user info failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

bool _isUpdateSuccess(dynamic data) {
  if (data == true || data == 1 || data == '1' || data == 'true') return true;
  if (data is Map<String, dynamic>) {
    final result = data['result'];
    return result == true ||
        result == 1 ||
        result?.toString() == '1' ||
        result?.toString().toLowerCase() == 'true';
  }
  return false;
}

Map<String, dynamic>? _resolveResultMap(dynamic data) {
  if (data is! Map<String, dynamic>) return null;
  final result = data['result'];
  if (result is Map<String, dynamic>) return result;
  return data;
}
