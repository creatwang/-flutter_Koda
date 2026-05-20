import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/profile/controllers/profile_providers.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/profile_settings_form_validators.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';

/// 个人中心页：设置校验与会话相关编排（无 Widget）。
abstract final class ProfilePageController {
  /// 合法返回 `null`，否则返回可直接展示的错误文案。
  static String? validateSettingsForm({
    required AppLocalizations l10n,
    required String fullName,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (fullName.trim().isEmpty) {
      return l10n.profileSettingsNameRequired;
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
        return l10n.profileSettingsPasswordFieldsRequired;
      }
      final hasShort =
          old.length < 6 || next.length < 6 || confirm.length < 6;
      if (hasShort) {
        return l10n.profileSettingsPasswordMinLength;
      }
    }

    if (next != confirm) {
      return l10n.profileSettingsPasswordMismatch;
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
