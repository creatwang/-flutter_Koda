import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

class AuthRequests {
  static const String loginPath = '/store/user/login';
  static const String siteInfoPath = '/store/siteInfo';
}

Future<Response<dynamic>> requestAuthLogin({
  required String username,
  required String password,
  DioClient? client,
}) {
  return (client ?? publicDioClient).post(
    AuthRequests.loginPath,
    data: {'username': username, 'password': password, 'terminal': 3},
  );
}

Future<Response<dynamic>> requestSiteInfo({
  required int companyId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    AuthRequests.siteInfoPath,
    queryParameters: <String, dynamic>{'company_id': companyId},
  );
}
