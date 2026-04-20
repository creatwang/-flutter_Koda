import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

/// 个人中心相关接口路径。
class ProfileRequests {
  ProfileRequests._();

  static const String userInfoPath = '/store/user/info';
  static const String orderListPath = '/store/order/lists';
  static const String customerOrderListPath =
      '/store/account/customerOrderList';
}

/// 获取当前用户信息（需鉴权）。
Future<Response<dynamic>> requestUserInfo({
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(ProfileRequests.userInfoPath);
}

/// 更新用户信息（需鉴权）。
///
/// [name]：展示名；密码相关字段可空，非空时参与请求体。
Future<Response<dynamic>> requestUpdateUserInfo({
  required String name,
  String? oldPassword,
  String? newPassword,
  String? conPassword,
  DioClient? client,
}) {
  final payload = <String, dynamic>{'name': name};
  if (oldPassword != null && oldPassword.trim().isNotEmpty) {
    payload['old_password'] = oldPassword;
  }
  if (newPassword != null && newPassword.trim().isNotEmpty) {
    payload['new_password'] = newPassword;
  }
  if (conPassword != null && conPassword.trim().isNotEmpty) {
    payload['con_password'] = conPassword;
  }

  return (client ?? protectedDioClient).post(
    ProfileRequests.userInfoPath,
    data: payload,
  );
}

/// 我的订单分页（需鉴权）。
///
/// [page] / [pageSize]：分页；[status] / [keyword]：筛选；
/// [withBatchOrder] / [allShop]：与后端约定一致。
Future<Response<dynamic>> requestOrderList({
  int page = 1,
  int pageSize = 20,
  String status = '',
  String keyword = '',
  int withBatchOrder = 1,
  int allShop = 1,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProfileRequests.orderListPath,
    queryParameters: <String, dynamic>{
      'status': status,
      'page': page,
      'page_size': pageSize,
      'keyword': keyword,
      'with_batch_order': withBatchOrder,
      'all_shop': allShop,
    },
  );
}

/// 客户订单分页（需鉴权，业务员场景）。
///
/// 参数语义同 [requestOrderList]。
Future<Response<dynamic>> requestCustomerOrderList({
  int page = 1,
  int pageSize = 20,
  String status = '',
  String keyword = '',
  int withBatchOrder = 1,
  int allShop = 1,
  int? userId,
  DioClient? client,
}) {
  final queryParameters = <String, dynamic>{
    'status': status,
    'page': page,
    'page_size': pageSize,
    'keyword': keyword,
    'with_batch_order': withBatchOrder,
    'all_shop': allShop,
  };
  if (userId != null) {
    queryParameters['user_id'] = userId;
  }
  return (client ?? protectedDioClient).get(
    ProfileRequests.customerOrderListPath,
    queryParameters: queryParameters,
  );
}
