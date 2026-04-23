import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/features/auth/models/remembered_login_form_dto.dart';

/// 读取上次登录表单（用户名在成功登录后常存；密码仅勾选记住时存在）。
Future<RememberedLoginFormDto?> readRememberedLoginFormService() async {
  final username = await secureStorageService.readRememberedLoginUsername();
  if (username == null || username.isEmpty) return null;
  final rawPassword = await secureStorageService.readRememberedLoginPassword();
  final password =
      rawPassword != null && rawPassword.isNotEmpty ? rawPassword : null;
  return RememberedLoginFormDto(username: username, password: password);
}

/// 登录成功后写入本地「记住」状态。
Future<void> persistRememberedLoginFormService({
  required String username,
  required String password,
  required bool shouldRememberPassword,
}) async {
  await secureStorageService.saveRememberedLoginUsername(username);
  if (shouldRememberPassword) {
    await secureStorageService.saveRememberedLoginPassword(password);
  } else {
    await secureStorageService.deleteRememberedLoginPassword();
  }
}
