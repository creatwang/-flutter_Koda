import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';
import 'package:groe_app_pad/features/profile/models/product_order_list_dto.dart';
import 'package:groe_app_pad/features/profile/api/profile_requests.dart';

Future<ApiResult<UserInfoBase>> fetchUserInfoService() async {
  try {
    final response = await requestUserInfo();
    final payload = _resolveResultMap(response.data);
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid user info response format',
      );
    }
    return ApiSuccess(UserInfoBase.fromJson(payload));
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

Future<ApiResult<ProductOrderListDto>> fetchProfileOrderListService({
  required int page,
  required int pageSize,
}) async {
  try {
    final response = await requestOrderList(
      page: page,
      pageSize: pageSize,
    );
    final payload = _resolveOrderListPayload(response.data);
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid profile order list response format',
      );
    }
    return ApiSuccess(ProductOrderListDto.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch profile order list failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<ProductOrderListDto>> fetchProfileCustomerOrderListService({
  required int page,
  required int pageSize,
}) async {
  try {
    final response = await requestCustomerOrderList(
      page: page,
      pageSize: pageSize,
    );
    final payload = _resolveOrderListPayload(response.data);
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid profile customer order list response format',
      );
    }
    return ApiSuccess(ProductOrderListDto.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch profile customer order list failed',
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

Map<String, dynamic>? _resolveOrderListPayload(dynamic data) {
  final root = _asMap(data);
  if (root == null) return null;
  final result = _asMap(root['result']);
  final dataNode = _asMap(root['data']);
  final candidates = <Map<String, dynamic>?>[result, dataNode, root];
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final items = candidate['items'];
    if (items is List) return candidate;
  }
  return null;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return null;
}
