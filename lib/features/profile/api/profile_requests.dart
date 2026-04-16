import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/core/platform_services/network_clients.dart';

class ProfileRequests {
  static const String userInfoPath = '/store/user/info';
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
