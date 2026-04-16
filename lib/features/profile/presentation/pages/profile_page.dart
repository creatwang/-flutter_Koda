import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_providers.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_favorites_section_widget.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';

enum ProfileContentSection {
  settings,
  myCustomers,
  orderCenter,
  favorites,
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  ProfileContentSection _currentSection = ProfileContentSection.settings;
  final TextEditingController _fullNameController =
      TextEditingController(text: 'Molin Chen');
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showSettingsValidation = false;
  String? _settingsErrorMessage;
  bool _isSavingSettings = false;
  bool _hasHydratedName = false;

  static const List<_ProfileSectionMeta> _menus = <_ProfileSectionMeta>[
    _ProfileSectionMeta(
      section: ProfileContentSection.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
    _ProfileSectionMeta(
      section: ProfileContentSection.myCustomers,
      label: 'My Customers',
      icon: Icons.groups_outlined,
    ),
    _ProfileSectionMeta(
      section: ProfileContentSection.orderCenter,
      label: 'Order Center',
      icon: Icons.notifications_none_outlined,
    ),
    _ProfileSectionMeta(
      section: ProfileContentSection.favorites,
      label: 'Favorites',
      icon: Icons.favorite_border,
    ),
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isFieldEmpty(TextEditingController controller) =>
      controller.text.trim().isEmpty;

  bool _validateSettingsForm() {
    if (_isFieldEmpty(_fullNameController)) {
      _settingsErrorMessage = 'Name is required.';
      return false;
    }

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final hasAnyPassword = _hasAnyPasswordInput(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (hasAnyPassword) {
      final hasMissingPassword =
          oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty;
      if (hasMissingPassword) {
        _settingsErrorMessage = 'Please complete all password fields.';
        return false;
      }
      final hasShortPassword = oldPassword.length < 6 ||
          newPassword.length < 6 ||
          confirmPassword.length < 6;
      if (hasShortPassword) {
        _settingsErrorMessage = 'Password must be at least 6 characters.';
        return false;
      }
    }

    if (newPassword != confirmPassword) {
      _settingsErrorMessage =
          'New Password and Confirm Password must match.';
      return false;
    }
    _settingsErrorMessage = null;
    return true;
  }

  Future<void> _onSaveSettings() async {
    setState(() => _showSettingsValidation = true);
    final isValid = _validateSettingsForm();
    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() => _isSavingSettings = true);
    final result = await ref.read(profileUserInfoProvider.notifier).updateUserInfo(
          name: _fullNameController.text.trim(),
          oldPassword: _oldPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
          conPassword: _confirmPasswordController.text.trim(),
        );
    if (!mounted) return;
    result.when(
      success: (_) {
        _settingsErrorMessage = null;
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully.')),
        );
      },
      failure: (exception) => _settingsErrorMessage = exception.message,
    );
    setState(() => _isSavingSettings = false);
  }

  Future<void> _onRefreshSettings() async {
    _settingsErrorMessage = null;
    await ref.read(profileUserInfoProvider.notifier).refresh();
    if (!mounted) return;
    final latestName = ref.read(profileUserInfoProvider).asData?.value.name;
    if (latestName != null && latestName.trim().isNotEmpty) {
      _fullNameController.text = latestName;
      _hasHydratedName = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeta = _menus.firstWhere(
      (item) => item.section == _currentSection,
    );
    final userInfoState = ref.watch(profileUserInfoProvider);
    final userName = userInfoState.asData?.value.name ?? '';
    final avatarUrl = userInfoState.asData?.value.avatar ?? '';
    final userId = userInfoState.asData?.value.id;
    if (!_hasHydratedName && userName.trim().isNotEmpty) {
      _fullNameController.text = userName;
      _hasHydratedName = true;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = MediaQuery.sizeOf(context);
        final fallbackHeight = viewport.height - 150;
        final resolvedHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight - 20
            : fallbackHeight;
        final panelHeight = resolvedHeight > 0 ? resolvedHeight : fallbackHeight;

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: SizedBox(
            height: panelHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: double.infinity,
                  child: _ProfileSidebar(
                    avatarUrl: avatarUrl,
                    profileName: userName,
                    profileId: userId,
                    currentSection: _currentSection,
                    menus: _menus,
                    onSectionChanged: (next) {
                      setState(() => _currentSection = next);
                      if (next == ProfileContentSection.favorites) {
                        ref.read(favoriteProductsProvider.notifier).refresh();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: _ProfileContentArea(
                      currentSection: _currentSection,
                      title: selectedMeta.label,
                      fullNameController: _fullNameController,
                      oldPasswordController: _oldPasswordController,
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      showValidation: _showSettingsValidation,
                      validationMessage: _settingsErrorMessage,
                      onSaveSettings: _onSaveSettings,
                      onRefreshSettings: _onRefreshSettings,
                      isSavingSettings: _isSavingSettings,
                      isLoadingUserInfo:
                          _currentSection == ProfileContentSection.settings &&
                              userInfoState.isLoading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileSidebar extends StatelessWidget {
  const _ProfileSidebar({
    required this.avatarUrl,
    required this.profileName,
    required this.profileId,
    required this.currentSection,
    required this.menus,
    required this.onSectionChanged,
  });

  final String avatarUrl;
  final String profileName;
  final int? profileId;
  final ProfileContentSection currentSection;
  final List<_ProfileSectionMeta> menus;
  final ValueChanged<ProfileContentSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 20, left: 10,right: 10,bottom: 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: -0.06, // 弧度
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEFF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.92),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3D67B2).withValues(alpha: 0.42),
                                  blurRadius: 12,
                                  spreadRadius: 0.5,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ColoredBox(
                                color: Colors.black26,
                                child: avatarUrl.trim().isEmpty
                                    ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                )
                                    : Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          profileName.trim().isEmpty ? '--' : profileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ID: ${profileId ?? '--'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            value: '128',
                            label: 'SAVED ITEMS',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            value: '24',
                            label: 'CONCEPTS',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'ACCOUNT & PREFERENCES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        letterSpacing: 1.5,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...menus.map((menu) {
                    final isSelected = menu.section == currentSection;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ProfileMenuTile(
                        label: menu.label,
                        icon: menu.icon,
                        selected: isSelected,
                        onTap: () => onSectionChanged(menu.section),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

bool _hasAnyPasswordInput({
  required String oldPassword,
  required String newPassword,
  required String confirmPassword,
}) {
  return oldPassword.trim().isNotEmpty ||
      newPassword.trim().isNotEmpty ||
      confirmPassword.trim().isNotEmpty;
}

String? _buildConfirmPasswordError({
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

String? _buildPasswordFieldError({
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

class _ProfileContentArea extends StatelessWidget {
  const _ProfileContentArea({
    required this.currentSection,
    required this.title,
    required this.fullNameController,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.showValidation,
    required this.validationMessage,
    required this.onSaveSettings,
    required this.onRefreshSettings,
    required this.isSavingSettings,
    required this.isLoadingUserInfo,
  });

  final ProfileContentSection currentSection;
  final String title;
  final TextEditingController fullNameController;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool showValidation;
  final String? validationMessage;
  final Future<void> Function() onSaveSettings;
  final Future<void> Function() onRefreshSettings;
  final bool isSavingSettings;
  final bool isLoadingUserInfo;

  @override
  Widget build(BuildContext context) {
    final isSettings = currentSection == ProfileContentSection.settings;
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final isPasswordGroupRequired = _hasAnyPasswordInput(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    final confirmPasswordError = _buildConfirmPasswordError(
      showValidation: showValidation,
      isPasswordGroupRequired: isPasswordGroupRequired,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    final oldPasswordError = _buildPasswordFieldError(
      showValidation: showValidation,
      isPasswordGroupRequired: isPasswordGroupRequired,
      value: oldPasswordController.text,
    );
    final newPasswordError = _buildPasswordFieldError(
      showValidation: showValidation,
      isPasswordGroupRequired: isPasswordGroupRequired,
      value: newPasswordController.text,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isSettings)
                  Material(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: isLoadingUserInfo ? null : () => onRefreshSettings(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white.withValues(
                            alpha: isLoadingUserInfo ? 0.45 : 0.92,
                          ),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (isSettings) ...[
              if (isLoadingUserInfo)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: viewInsetsBottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.person, color: Colors.white.withValues(alpha: 0.72), size: 20,),
                                const SizedBox(width: 4),
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _SettingsInputField(
                                    label: 'FULL NAME',
                                    controller: fullNameController,
                                    obscureText: false,
                                    errorMessage: showValidation &&
                                            fullNameController.text.trim().isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _SettingsInputField(
                                    label: 'OLD PASSWORD',
                                    controller: oldPasswordController,
                                    obscureText: true,
                                    errorMessage: oldPasswordError,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _SettingsInputField(
                                    label: 'NEW PASSWORD',
                                    controller: newPasswordController,
                                    obscureText: true,
                                    errorMessage: newPasswordError,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _SettingsInputField(
                                    label: 'CONFIRM PASSWORD',
                                    controller: confirmPasswordController,
                                    obscureText: true,
                                    errorMessage: confirmPasswordError,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (validationMessage != null)
                              SelectableText.rich(
                                TextSpan(
                                  text: validationMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (validationMessage != null)
                              const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                onPressed: isSavingSettings
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Another Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(
                            child: _SettingsActionTile(
                              icon: Icons.compare_arrows_rounded,
                              text: 'switch  Account',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _SettingsActionTile(
                              icon: Icons.power_settings_new,
                              text: 'logout',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              Expanded(
                child: currentSection == ProfileContentSection.favorites
                    ? const ProfileFavoritesSectionWidget()
                    : AppEmptyView(
                        message: '$title is empty',
                        width: 130,
                        height: 130,
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Colors.black.withValues(alpha: 0.32)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.24)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsInputField extends StatelessWidget {
  const _SettingsInputField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.errorMessage,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.86),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onTap: () async {
            // 键盘弹出后再次确保当前输入框处于可视区。
            await Future<void>.delayed(const Duration(milliseconds: 220));
            if (!context.mounted) return;
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: 0.2,
            );
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            constraints: const BoxConstraints(
              minHeight: 40,
              maxHeight: 40,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            hintText: obscureText ? '********' : 'Molin Chen',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            errorText: errorMessage,
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 8,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionMeta {
  const _ProfileSectionMeta({
    required this.section,
    required this.label,
    required this.icon,
  });

  final ProfileContentSection section;
  final String label;
  final IconData icon;
}
