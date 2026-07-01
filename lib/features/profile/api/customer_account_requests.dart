import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/network/interceptors/response_data_mode_interceptor.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';

class CustomerAccountRequests {
  CustomerAccountRequests._();

  static const String customerListPath = '/store/account/customer';
  static const String customerUpdatePath = '/store/account/customerUpdate';
  static const String customerCreatePath = '/store/account/customerCreate';
  static const String customerLoginPath = '/store/account/customerLogin';
  static const String customerDeletePath = '/store/account/customerDelete';
  static const String customerResetPwdPath = '/store/account/customerResetPwd';

  static const int padTerminal = 5;
}

Future<Response<dynamic>> requestStoreCustomerList({
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
    },
  );
}

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
    options: Options(
      extra: <String, dynamic>{
        ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey: true,
      },
    ),
  );
}

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
    simpleResponse: false,
    options: Options(
      extra: <String, dynamic>{
        ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey: true,
      },
    ),
  );
}

Future<Response<dynamic>> requestStoreCustomerLogin({
  required int id,
  int terminal = CustomerAccountRequests.padTerminal,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CustomerAccountRequests.customerLoginPath,
    data: <String, dynamic>{'id': id, 'terminal': terminal},
  );
}

Future<Response<dynamic>> requestStoreCustomerDelete({
  required int id,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CustomerAccountRequests.customerDeletePath,
    data: <String, dynamic>{'id': id},
  );
}

Future<Response<dynamic>> requestStoreCustomerResetPwd({
  required String password,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    CustomerAccountRequests.customerResetPwdPath,
    data: <String, dynamic>{'password': password},
  );
}
