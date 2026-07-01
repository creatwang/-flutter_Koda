import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/profile/api/profile_requests.dart';
import 'package:george_pick_mate/features/profile/models/product_order_list_dto.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

/// 个人中心：用户信息、订单列表等业务封装与响应适配。
Future<ApiResult<UserInfoBase>> fetchUserInfoService() async {
  try {
    final response = await requestUserInfo();
    final payload = resolveUserInfoPayload(response.data);
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidUserInfoResponseFormat,
      );
    }
    return ApiSuccess(UserInfoBase.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchUserInfoFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 更新用户资料（含可选改密字段）。
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
      error: failureMessage ?? appL10n.errorUpdateUserInfoFailed,
      message: failureMessage ?? appL10n.errorUpdateUserInfoFailed,
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorUpdateUserInfoFailed,
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
}) {
  return _fetchOrderListPage(
    request: () => requestOrderList(page: page, pageSize: pageSize),
  );
}

Future<ApiResult<ProductOrderListDto>> fetchProfileCustomerOrderListService({
  required int page,
  required int pageSize,
}) {
  return _fetchOrderListPage(
    request: () =>
        requestCustomerOrderList(page: page, pageSize: pageSize),
  );
}

Future<ApiResult<ProductOrderListDto>>
fetchProfileCustomerOrderListForUserService({
  required int userId,
  required int page,
  required int pageSize,
}) {
  return _fetchOrderListPage(
    request: () => requestCustomerOrderList(
      page: page,
      pageSize: pageSize,
      userId: userId,
    ),
  );
}

Future<ApiResult<ProductOrderListDto>> _fetchOrderListPage({
  required Future<Response<dynamic>> Function() request,
}) async {
  try {
    final response = await request();
    final payload = _resolveOrderListPayload(response.data);
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: appL10n.errorInvalidOrderListResponseFormat,
      );
    }
    return ApiSuccess(ProductOrderListDto.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchOrderListFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

bool _isUpdateSuccess(dynamic data) {
  if (data == true || data == 1 || data == '1' || data == 'true') {
    return true;
  }
  if (data is Map<String, dynamic>) {
    final result = data['result'];
    return result == true ||
        result == 1 ||
        result?.toString() == '1' ||
        result?.toString().toLowerCase() == 'true';
  }
  return false;
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
