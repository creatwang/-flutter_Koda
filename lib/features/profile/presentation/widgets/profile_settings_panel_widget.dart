import 'package:flutter/material.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_glass_card_widget.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_input_field_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_settings_account_action_button_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_settings_form_validators.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 设置分区：个人信息、密码与账号操作（不含顶部进度条）。
class ProfileSettingsPanelWidget extends StatelessWidget {
  const ProfileSettingsPanelWidget({
    super.key,
    required this.viewInsetsBottom,
    required this.fullNameController,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.showValidation,
    required this.validationMessage,
    required this.onSaveSettings,
    required this.onOpenSwitchSiteSheet,
    required this.showSwitchSiteEntry,
    required this.hasMainAccountSnapshot,
    required this.onSignOut,
    required this.onSwitchAccount,
    required this.isSigningOut,
    required this.isSwitchingAccount,
    required this.isSavingSettings,
  });

  final double viewInsetsBottom;
  final TextEditingController fullNameController;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool showValidation;
  final String? validationMessage;
  final Future<void> Function() onSaveSettings;
  final Future<void> Function() onOpenSwitchSiteSheet;
  final bool showSwitchSiteEntry;
  final bool hasMainAccountSnapshot;
  final Future<void> Function() onSignOut;
  final Future<void> Function() onSwitchAccount;
  final bool isSigningOut;
  final bool isSwitchingAccount;
  final bool isSavingSettings;

  Future<void> _ensureFieldVisible(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!context.mounted) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordGroupRequired = profileSettingsHasAnyPasswordInput(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    final confirmPasswordError = profileSettingsConfirmPasswordError(
      showValidation: showValidation,
      isPasswordGroupRequired: isPasswordGroupRequired,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    final oldPasswordError = profileSettingsPasswordFieldError(
      showValidation: showValidation,
      isPasswordGroupRequired: isPasswordGroupRequired,
      value: oldPasswordController.text,
    );
    final newPasswordError = profileSettingsPasswordFieldError(
      showValidation: showValidation,
      isPasswordGroupRequired: isPasswordGroupRequired,
      value: newPasswordController.text,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Settings',
            style: TextStyle(
              color: ProMaxTokens.iconPrimary,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          ProMaxGlassCardWidget(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white.withValues(alpha: 0.72),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ProMaxInputFieldWidget(
                        label: 'FULL NAME',
                        controller: fullNameController,
                        obscureText: false,
                        onTap: () => _ensureFieldVisible(context),
                        errorText: showValidation &&
                                fullNameController.text.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ProMaxInputFieldWidget(
                        label: 'OLD PASSWORD',
                        controller: oldPasswordController,
                        obscureText: true,
                        onTap: () => _ensureFieldVisible(context),
                        errorText: oldPasswordError,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ProMaxInputFieldWidget(
                        label: 'NEW PASSWORD',
                        controller: newPasswordController,
                        obscureText: true,
                        onTap: () => _ensureFieldVisible(context),
                        errorText: newPasswordError,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ProMaxInputFieldWidget(
                        label: 'CONFIRM PASSWORD',
                        controller: confirmPasswordController,
                        obscureText: true,
                        onTap: () => _ensureFieldVisible(context),
                        errorText: confirmPasswordError,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const SizedBox(height: 2),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: validationMessage == null
                              ? const SizedBox.shrink()
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0x26FF6E76),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0x55FF7F86),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          size: 14,
                                          color: Color(0xFFFFA9AD),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: SelectableText.rich(
                                            TextSpan(
                                              text: validationMessage!,
                                              style: const TextStyle(
                                                color: Color(0xFFFFC8CB),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: isSavingSettings || isSigningOut
                            ? null
                            : () => onSaveSettings(),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: isSavingSettings
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ProMaxGlassCardWidget(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Another  Settings',
                        style: TextStyle(
                          color: ProMaxTokens.iconPrimary,
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (showSwitchSiteEntry)
                      Tooltip(
                        message: 'Switch site',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onOpenSwitchSiteSheet(),
                            borderRadius: BorderRadius.circular(4),
                            child: Ink(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    Color(0x55F4C77A),
                                    Color(0x28FFC9A8),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0x88F4C77A),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(0x33F4C77A),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.swap_horiz_rounded,
                                  color: Color(0xFFF4E6C8),
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Manage your active session and sign-in account.',
                  style: TextStyle(
                    color: ProMaxTokens.textSecondary.withValues(alpha: 0.92),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                if (hasMainAccountSnapshot)
                  Row(
                    children: [
                      Expanded(
                        child: ProfileSettingsAccountActionButtonWidget(
                          icon: Icons.switch_account_rounded,
                          title: 'Switch Account',
                          subtitle: 'Switch back to original account',
                          onTap: onSwitchAccount,
                          isLoading: isSwitchingAccount,
                          isEnabled: !isSigningOut,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ProfileSettingsAccountActionButtonWidget(
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          subtitle: 'Exit current account',
                          isDanger: true,
                          onTap: onSignOut,
                          isLoading: isSigningOut,
                          isEnabled: !isSwitchingAccount,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ProfileSettingsAccountActionButtonWidget(
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          subtitle: 'Exit current account',
                          isDanger: true,
                          onTap: onSignOut,
                          isLoading: isSigningOut,
                          isEnabled: !isSwitchingAccount,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
