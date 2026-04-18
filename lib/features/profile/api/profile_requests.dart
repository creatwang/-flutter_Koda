import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

class ProfileRequests {
  static const String userInfoPath = '/store/user/info';
  static const String orderListPath = '/store/order/lists';
  static const String customerOrderListPath = '/store/account/customerOrderList';
}

Future<Response<dynamic>> requestUserInfo({
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(ProfileRequests.userInfoPath);
}

Future<Response<dynamic>> requestUpdateUserInfo({
  required String name,
  String? oldPassword,
  String? newPassword,
  String? conPassword,
  DioClient? client,
}) {
  final payload = <String, dynamic>{
    'name': name,
  };
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
    queryParameters: {
      'status': status,
      'page': page,
      'page_size': pageSize,
      'keyword': keyword,
      'with_batch_order': withBatchOrder,
      'all_shop': allShop,
    },
  );
}

Future<Response<dynamic>> requestCustomerOrderList({
  int page = 1,
  int pageSize = 20,
  String status = '',
  String keyword = '',
  int withBatchOrder = 1,
  int allShop = 1,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProfileRequests.customerOrderListPath,
    queryParameters: {
      'status': status,
      'page': page,
      'page_size': pageSize,
      'keyword': keyword,
      'with_batch_order': withBatchOrder,
      'all_shop': allShop,
    },
  );
}
