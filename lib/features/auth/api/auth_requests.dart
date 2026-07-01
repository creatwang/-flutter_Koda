import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/network/interceptors/response_data_mode_interceptor.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';

/// 认证与站点原始接口路径（不含业务解析）。
class AuthRequests {
  AuthRequests._();

  static const String loginPath = '/store/user/login';
  static const String registerPath = '/store/user/register';
  static const String logoutPath = '/store/user/logout';
  static const String siteInfoPath = '/store/siteInfo';
}

Future<Response<dynamic>> requestAuthLogin({
  required String username,
  required String password,
  DioClient? client,
}) {
  return (client ?? publicDioClient).post(
    AuthRequests.loginPath,
    data: <String, dynamic>{
      'username': username,
      'password': password,
      'terminal': 3,
    },
    options: Options(
      extra: <String, dynamic>{
        ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey: true,
      },
    ),
  );
}

Future<Response<dynamic>> requestAuthRegister({
  required String username,
  required String password,
  required String passwordConfirm,
  DioClient? client,
}) {
  return (client ?? publicDioClient).post(
    AuthRequests.registerPath,
    data: <String, dynamic>{
      'terminal': 5,
      'username': username,
      'password': password,
      'passwordConfirm': passwordConfirm,
    },
    options: Options(
      extra: <String, dynamic>{
        ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey: true,
      },
    ),
  );
}

Future<Response<dynamic>> requestAuthLogout({DioClient? client}) {
  return (client ?? protectedDioClient).post(AuthRequests.logoutPath);
}

Future<Response<dynamic>> requestSiteInfo({DioClient? client}) {
  return (client ?? protectedDioClient).get(AuthRequests.siteInfoPath);
}
