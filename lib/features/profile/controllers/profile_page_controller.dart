import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_providers.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_settings_form_validators.dart';

/// 个人中心页：设置校验与会话相关编排（无 Widget）。
abstract final class ProfilePageController {
  /// 合法返回 `null`，否则返回可直接展示的错误文案。
  static String? validateSettingsForm({
    required String fullName,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (fullName.trim().isEmpty) {
      return 'Name is required.';
    }

    final old = oldPassword.trim();
    final next = newPassword.trim();
    final confirm = confirmPassword.trim();
    final hasAny = profileSettingsHasAnyPasswordInput(
      oldPassword: old,
      newPassword: next,
      confirmPassword: confirm,
    );

    if (hasAny) {
      final hasMissing = old.isEmpty || next.isEmpty || confirm.isEmpty;
      if (hasMissing) {
        return 'Please complete all password fields.';
      }
      final hasShort =
          old.length < 6 || next.length < 6 || confirm.length < 6;
      if (hasShort) {
        return 'Password must be at least 6 characters.';
      }
    }

    if (next != confirm) {
      return 'New Password and Confirm Password must match.';
    }
    return null;
  }

  static Future<ApiResult<void>> updateUserInfo(
    WidgetRef ref, {
    required String name,
    required String oldPassword,
    required String newPassword,
    required String conPassword,
  }) {
    return ref.read(profileUserInfoProvider.notifier).updateUserInfo(
          name: name,
          oldPassword: oldPassword,
          newPassword: newPassword,
          conPassword: conPassword,
        );
  }

  static Future<void> refreshProfile(WidgetRef ref) =>
      ref.read(profileUserInfoProvider.notifier).refresh();

  static Future<ApiResult<void>> signOutWithRemoteLogout(WidgetRef ref) =>
      ref.read(sessionControllerProvider.notifier).signOutWithRemoteLogout();

  static Future<ApiResult<void>> switchBackToMainUser(WidgetRef ref) =>
      ref.read(sessionControllerProvider.notifier).switchBackToMainUser();
}
