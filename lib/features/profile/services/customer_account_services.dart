import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/auth/models/user_info_bean.dart';
import 'package:groe_app_pad/features/profile/api/customer_account_requests.dart';
import 'package:groe_app_pad/features/profile/models/paginated_store_customers_state.dart';
import 'package:groe_app_pad/features/profile/models/store_customer_item_dto.dart';

/// 拉取客户列表第一页（含筛选参数）。
Future<ApiResult<PaginatedStoreCustomersState>>
fetchStoreCustomersFirstPageService({
  required int companyId,
  String status = '',
  String keyword = '',
  int pageSize = 20,
}) async {
  try {
    final response = await requestStoreCustomerList(
      companyId: companyId,
      page: 1,
      pageSize: pageSize,
      status: status,
      keyword: keyword,
    );
    final page = _parseCustomerListPage(
      response.data,
      page: 1,
      pageSize: pageSize,
    );
    if (page == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid customer list response',
      );
    }
    return ApiSuccess(page);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch customers failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 拉取指定页客户列表（分页加载更多）。
Future<ApiResult<PaginatedStoreCustomersState>> fetchStoreCustomersPageService({
  required int companyId,
  required int page,
  String status = '',
  String keyword = '',
  int pageSize = 20,
}) async {
  try {
    final response = await requestStoreCustomerList(
      companyId: companyId,
      page: page,
      pageSize: pageSize,
      status: status,
      keyword: keyword,
    );
    final parsed = _parseCustomerListPage(
      response.data,
      page: page,
      pageSize: pageSize,
    );
    if (parsed == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid customer list response',
      );
    }
    return ApiSuccess(parsed);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch customers failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 新增客户账号。
Future<ApiResult<void>> createStoreCustomerService({
  required String username,
  required String password,
  required String name,
  required String telephone,
}) async {
  try {
    final response = await requestStoreCustomerCreate(
      username: username,
      password: password,
      name: name,
      telephone: telephone,
    );
    if (_isMutationSuccess(response.data)) {
      return const ApiSuccess(null);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: _messageFromBody(response.data) ?? 'Create customer failed',
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Create customer failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 修改客户账号。
Future<ApiResult<void>> updateStoreCustomerService({
  required int id,
  required String username,
  required String password,
  required String name,
  required String telephone,
}) async {
  try {
    final response = await requestStoreCustomerUpdate(
      id: id,
      username: username,
      password: password,
      name: name,
      telephone: telephone,
    );
    if (_isMutationSuccess(response.data)) {
      return const ApiSuccess(null);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: _messageFromBody(response.data) ?? 'Update customer failed',
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Update customer failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 设置客户公共密码（`POST /store/account/customerResetPwd`）。
Future<ApiResult<void>> resetStoreCustomerCommonPasswordService({
  required String password,
}) async {
  try {
    final response = await requestStoreCustomerResetPwd(password: password);
    if (_isMutationSuccess(response.data)) {
      return const ApiSuccess(null);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message:
          _messageFromBody(response.data) ?? 'Reset common password failed',
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Reset common password failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 删除客户账号。
Future<ApiResult<void>> deleteStoreCustomerService({required int id}) async {
  try {
    final response = await requestStoreCustomerDelete(id: id);
    if (_isMutationSuccess(response.data)) {
      return const ApiSuccess(null);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: _messageFromBody(response.data) ?? 'Delete customer failed',
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Delete customer failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 代客登录：返回与客户一致的 [UserInfoBase]（含 token）。
Future<ApiResult<UserInfoBase>> loginStoreCustomerService({
  required int id,
}) async {
  try {
    final response = await requestStoreCustomerLogin(id: id);
    final payload = _resolveResultMap(response.data);
    if (payload == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid customer login response',
      );
    }
    return ApiSuccess(UserInfoBase.fromJson(payload));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Customer login failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Map<String, dynamic>? _resolveResultMap(dynamic data) {
  if (data is! Map<String, dynamic>) return null;
  final result = data['result'];
  if (result is Map<String, dynamic>) return result;
  return data;
}

PaginatedStoreCustomersState? _parseCustomerListPage(
  dynamic data, {
  required int page,
  required int pageSize,
}) {
  final root = _resolveResultMap(data);
  if (root == null) return null;
  final itemsRaw = root['items'];
  if (itemsRaw is! List) return null;
  final items = <StoreCustomerItemDto>[];
  for (final dynamic e in itemsRaw) {
    if (e is Map<String, dynamic>) {
      items.add(StoreCustomerItemDto.fromJson(e));
    } else if (e is Map) {
      items.add(StoreCustomerItemDto.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  final total = _readInt(root['total']) ?? items.length;
  final alreadyLoaded = (page - 1) * pageSize + items.length;
  final hasMore = alreadyLoaded < total && items.isNotEmpty;
  return PaginatedStoreCustomersState(
    items: items,
    page: page,
    hasMore: hasMore,
    totalCount: total,
  );
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// 标准成功包：
/// `{ "code": 0, "message": "ok", "type": "success", "result": true }`
bool _isMutationSuccess(dynamic data) {
  if (data == true || data == 1 || data == '1' || data == 'true') {
    return true;
  }
  if (data is! Map) return false;
  final map = Map<String, dynamic>.from(data);
  final code = map['code'];
  if (code is num && code != 0) return false;
  if (code is String) {
    final cs = code.trim().toLowerCase();
    if (cs != '0' && cs != 'success') return false;
  }

  final dynamic result = map['result'];
  if (map.containsKey('result')) {
    if (result == false ||
        result == 0 ||
        result?.toString().toLowerCase() == 'false' ||
        result?.toString() == '0') {
      return false;
    }
  }

  final type = map['type']?.toString().toLowerCase();
  if (type == 'success') return true;
  if (code is num && code == 0) return true;
  if (code is String && code.trim() == '0') return true;

  return result == true ||
      result == 1 ||
      result?.toString() == '1' ||
      result?.toString().toLowerCase() == 'true';
}

String? _messageFromBody(dynamic data) {
  if (data is Map) {
    return Map<String, dynamic>.from(data)['message']?.toString();
  }
  return null;
}
