import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/auth/models/remembered_login_form_dto.dart';
import 'package:george_pick_mate/features/auth/services/auth_login_remember_services.dart';

/// 登录成功后将账号/可选密码写入本地（单测可 override）。
typedef PersistRememberedLoginForm = Future<void> Function({
  required String username,
  required String password,
  required bool shouldRememberPassword,
});

final persistRememberedLoginFormProvider =
    Provider<PersistRememberedLoginForm>(
  (ref) => persistRememberedLoginFormService,
);

/// 进入登录页时读取一次本地记住的账号/密码。
final rememberedLoginFormProvider =
    FutureProvider.autoDispose<RememberedLoginFormDto?>((ref) async {
  return readRememberedLoginFormService();
});
