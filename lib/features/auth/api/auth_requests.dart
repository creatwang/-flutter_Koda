import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

class AuthRequests {
  static const String loginPath = '/auth/login';
}

Future<Response<dynamic>> requestAuthLogin({
  required String username,
  required String password,
  DioClient? client,
}) {
  return (client ?? publicDioClient).post(
    AuthRequests.loginPath,
    data: {
      'username': username,
      'password': password,
    },
  );
}
