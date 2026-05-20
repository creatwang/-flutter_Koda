import 'package:george_pick_mate/l10n/app_localizations.dart';

bool profileSettingsHasAnyPasswordInput({
  required String oldPassword,
  required String newPassword,
  required String confirmPassword,
}) {
  return oldPassword.trim().isNotEmpty ||
      newPassword.trim().isNotEmpty ||
      confirmPassword.trim().isNotEmpty;
}

String? profileSettingsConfirmPasswordError({
  required AppLocalizations l10n,
  required bool showValidation,
  required bool isPasswordGroupRequired,
  required String newPassword,
  required String confirmPassword,
}) {
  if (!showValidation) return null;
  if (isPasswordGroupRequired && confirmPassword.trim().isEmpty) {
    return l10n.commonRequired;
  }
  if (confirmPassword.trim().isNotEmpty &&
      confirmPassword.trim().length < 6) {
    return l10n.commonMinSixCharsShort;
  }
  if (newPassword.trim().isNotEmpty &&
      newPassword.trim() != confirmPassword.trim()) {
    return l10n.commonNotMatch;
  }
  return null;
}

String? profileSettingsPasswordFieldError({
  required AppLocalizations l10n,
  required bool showValidation,
  required bool isPasswordGroupRequired,
  required String value,
}) {
  if (!showValidation) return null;
  final input = value.trim();
  if (isPasswordGroupRequired && input.isEmpty) return l10n.commonRequired;
  if (input.isNotEmpty && input.length < 6) {
    return l10n.commonMinSixCharsShort;
  }
  return null;
}
