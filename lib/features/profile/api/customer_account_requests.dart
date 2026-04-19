import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

/// 业务员客户账号相关路径（仅 HTTP）。
class CustomerAccountRequests {
  CustomerAccountRequests._();

  static const String customerListPath = '/store/account/customer';
  static const String customerUpdatePath = '/store/account/customerUpdate';
  static const String customerCreatePath = '/store/account/customerCreate';
  static const String customerLoginPath = '/store/account/customerLogin';
  static const String customerDeletePath = '/store/account/customerDelete';

  /// 平板端与门店切换等接口一致。
  static const int padTerminal = 5;
}

/// 客户分页列表（需鉴权）。
Future<Response<dynamic>> requestStoreCustomerList({
  required int companyId,
  int page = 1,
  int pageSize = 20,
  String status = '',
  String keyword = '',
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    CustomerAccountRequests.customerListPath,
    queryParameters: <String, dynamic>{
      'status': status,
      'page': page,
      'page_size': pageSize,
      'keyword': keyword,
      'company_id': companyId,
    },
  );
}

/// 修改客户账号（需鉴权）。
Future<Response<dynamic>> requestStoreCustomerUpdate({
  required int id,
  required String username,
  required String password,
  required String name,
  required String telephone,
  int terminal = CustomerAccountRequests.padTerminal,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CustomerAccountRequests.customerUpdatePath,
    data: <String, dynamic>{
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'telephone': telephone,
      'terminal': terminal,
    },
  );
}

/// 新增客户账号（需鉴权）。
Future<Response<dynamic>> requestStoreCustomerCreate({
  required String username,
  required String password,
  required String name,
  required String telephone,
  int terminal = CustomerAccountRequests.padTerminal,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CustomerAccountRequests.customerCreatePath,
    data: <String, dynamic>{
      'username': username,
      'password': password,
      'name': name,
      'telephone': telephone,
      'terminal': terminal,
    },
  );
}

/// 代客登录（需鉴权，业务员上下文）。
Future<Response<dynamic>> requestStoreCustomerLogin({
  required int id,
  int terminal = CustomerAccountRequests.padTerminal,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CustomerAccountRequests.customerLoginPath,
    data: <String, dynamic>{
      'id': id,
      'terminal': terminal,
    },
  );
}

/// 删除客户账号（需鉴权）。
Future<Response<dynamic>> requestStoreCustomerDelete({
  required int id,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CustomerAccountRequests.customerDeletePath,
    data: <String, dynamic>{
      'id': id,
    },
  );
}
