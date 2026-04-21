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
  required bool showValidation,
  required bool isPasswordGroupRequired,
  required String newPassword,
  required String confirmPassword,
}) {
  if (!showValidation) return null;
  if (isPasswordGroupRequired && confirmPassword.trim().isEmpty) {
    return 'Required';
  }
  if (confirmPassword.trim().isNotEmpty &&
      confirmPassword.trim().length < 6) {
    return 'Min 6 chars';
  }
  if (newPassword.trim().isNotEmpty &&
      newPassword.trim() != confirmPassword.trim()) {
    return 'Not match';
  }
  return null;
}

String? profileSettingsPasswordFieldError({
  required bool showValidation,
  required bool isPasswordGroupRequired,
  required String value,
}) {
  if (!showValidation) return null;
  final input = value.trim();
  if (isPasswordGroupRequired && input.isEmpty) return 'Required';
  if (input.isNotEmpty && input.length < 6) return 'Min 6 chars';
  return null;
}
