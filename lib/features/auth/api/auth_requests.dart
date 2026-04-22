import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/network/interceptors/response_data_mode_interceptor.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

/// 认证与站点原始接口路径（不含业务解析）。
class AuthRequests {
  AuthRequests._();

  /// `POST /store/user/login`
  static const String loginPath = '/store/user/login';

  /// `POST /store/user/register`
  static const String registerPath = '/store/user/register';

  /// `POST /store/user/logout`（开放接口，无需 token）。
  static const String logoutPath = '/store/user/logout';

  /// `GET /store/siteInfo`
  static const String siteInfoPath = '/store/siteInfo';
}

/// 用户登录（开放接口，无需 token）。
///
/// [username] / [password]：账号凭证。
/// [client]：可选，默认 [publicDioClient]。
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
  );
}

/// 用户注册（开放接口）。
///
/// 默认抑制全局错误提示，由登录页自行展示 [SnackBar]。
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

/// 拉取站点配置（需鉴权）。
///
/// [companyId]：当前站点 id，作为 `company_id` 查询参数。
/// [client]：可选，默认 [protectedDioClient]。
Future<Response<dynamic>> requestSiteInfo({
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    AuthRequests.siteInfoPath,
    queryParameters: <String, dynamic>{'company_id': companyId},
  );
}
