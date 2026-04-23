import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/profile/api/profile_requests.dart';
import 'package:george_pick_mate/features/profile/models/product_order_list_dto.dart';

/// 个人中心：用户信息、订单列表等业务封装与响应适配。
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

/// 更新用户资料（含可选改密字段）。
///
/// [name]：姓名；[oldPassword] / [newPassword] / [conPassword]：改密三栏，
/// 可传空串表示不改密。
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

/// 我的订单第一页及分页加载（内部与 [fetchProfileCustomerOrderListService]
/// 共用解析逻辑）。
Future<ApiResult<ProductOrderListDto>> fetchProfileOrderListService({
  required int page,
  required int pageSize,
}) {
  return _fetchOrderListPage(
    request: () => requestOrderList(page: page, pageSize: pageSize),
  );
}

/// 客户订单分页（业务员）。
Future<ApiResult<ProductOrderListDto>> fetchProfileCustomerOrderListService({
  required int page,
  required int pageSize,
}) {
  return _fetchOrderListPage(
    request: () =>
        requestCustomerOrderList(page: page, pageSize: pageSize),
  );
}

/// 指定客户 `user_id` 的订单分页（与 Order Center Customer 同源接口）。
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
        error: 'Invalid order list response format',
      );
    }
    return ApiSuccess(ProductOrderListDto.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch order list failed',
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
