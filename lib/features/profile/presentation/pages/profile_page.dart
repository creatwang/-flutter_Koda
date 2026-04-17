import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_providers.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_favorites_section_widget.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_glass_card_widget.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_input_field_widget.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

enum ProfileContentSection { settings, myCustomers, orderCenter, favorites }

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  ProfileContentSection _currentSection = ProfileContentSection.settings;
  final TextEditingController _fullNameController = TextEditingController(
    text: 'Molin Chen',
  );
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
      final hasShortPassword =
          oldPassword.length < 6 ||
          newPassword.length < 6 ||
          confirmPassword.length < 6;
      if (hasShortPassword) {
        _settingsErrorMessage = 'Password must be at least 6 characters.';
        return false;
      }
    }

    if (newPassword != confirmPassword) {
      _settingsErrorMessage = 'New Password and Confirm Password must match.';
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
    final result = await ref
        .read(profileUserInfoProvider.notifier)
        .updateUserInfo(
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Updated successfully.')));
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

  Future<void> _onSignOut() async {
    await ref.read(sessionControllerProvider.notifier).signOut();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Future<void> _onSwitchAccount() async {
    await ref.read(sessionControllerProvider.notifier).signOut();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeta = _menus.firstWhere(
      (item) => item.section == _currentSection,
    );
    final userInfoState = ref.watch(profileUserInfoProvider);
    final favoriteState = ref.watch(favoriteProductsProvider);
    final favoriteData = favoriteState.asData?.value;
    final favoriteCount =
        favoriteData?.totalCount ?? favoriteData?.items.length ?? 0;
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
        final panelHeight = resolvedHeight > 0
            ? resolvedHeight
            : fallbackHeight;

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
                    favoriteCount: favoriteCount,
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
                      onSignOut: _onSignOut,
                      onSwitchAccount: _onSwitchAccount,
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
    required this.favoriteCount,
    required this.currentSection,
    required this.menus,
    required this.onSectionChanged,
  });

  final String avatarUrl;
  final String profileName;
  final int? profileId;
  final int favoriteCount;
  final ProfileContentSection currentSection;
  final List<_ProfileSectionMeta> menus;
  final ValueChanged<ProfileContentSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return ProMaxGlassCardWidget(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 230,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
                bottom: 18,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
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
                                  color: const Color(
                                    0xFF3D67B2,
                                  ).withValues(alpha: 0.42),
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
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
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
                          'UID: ${profileId ?? '--'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            letterSpacing: 1.4,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              value: '$favoriteCount',
                              label: 'FAV NUM',
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: _StatTile(value: '24', label: 'CONCEPTS'),
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
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: 1.6,
                          fontSize: 11,
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
  if (confirmPassword.trim().isNotEmpty && confirmPassword.trim().length < 6) {
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
    required this.onSignOut,
    required this.onSwitchAccount,
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
  final Future<void> Function() onSignOut;
  final Future<void> Function() onSwitchAccount;
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
    Future<void> ensureFieldVisible() async {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!context.mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.2,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ProMaxTokens.panelBackground,
        borderRadius: BorderRadius.circular(ProMaxTokens.radiusPanel),
        border: Border.all(color: ProMaxTokens.panelBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ProMaxTokens.space5,
          18,
          ProMaxTokens.space5,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: ProMaxTokens.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      shadows: const [
                        Shadow(
                          color: Color(0x55000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSettings)
                  Material(
                    color: ProMaxTokens.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: isLoadingUserInfo
                          ? null
                          : () => onRefreshSettings(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 19,
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
                                    onTap: ensureFieldVisible,
                                    errorText:
                                        showValidation &&
                                            fullNameController.text
                                                .trim()
                                                .isEmpty
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
                                    onTap: ensureFieldVisible,
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
                                    onTap: ensureFieldVisible,
                                    errorText: newPasswordError,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: ProMaxInputFieldWidget(
                                    label: 'CONFIRM PASSWORD',
                                    controller: confirmPasswordController,
                                    obscureText: true,
                                    onTap: ensureFieldVisible,
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
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: const Color(
                                                    0x55FF7F86,
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .error_outline_rounded,
                                                      size: 14,
                                                      color: Color(0xFFFFA9AD),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: SelectableText.rich(
                                                        TextSpan(
                                                          text:
                                                              validationMessage!,
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFFFFC8CB,
                                                                ),
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      ProMaxGlassCardWidget(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Actions',
                              style: TextStyle(
                                color: ProMaxTokens.iconPrimary,
                                fontSize: 12,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Manage your active session and sign-in account.',
                              style: TextStyle(
                                color: ProMaxTokens.textSecondary.withValues(
                                  alpha: 0.92,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _SettingsAccountActionButton(
                                    icon: Icons.switch_account_rounded,
                                    title: 'Switch Account',
                                    subtitle: 'Sign in with another account',
                                    onTap: onSwitchAccount,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SettingsAccountActionButton(
                                    icon: Icons.logout_rounded,
                                    title: 'Sign Out',
                                    subtitle: 'Exit current account',
                                    isDanger: true,
                                    onTap: onSignOut,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
    const selectedTextColor = Color(0xFFD5DAE2);
    const selectedIconColor = Color(0xFFB8C0CC);
    const selectedBorderColor = Color(0x66737E8D);
    const unselectedBorderColor = Color(0x33FFFFFF);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? const [Color(0x5639404A), Color(0x3A1E232B)]
                  : const [Color(0x14FFFFFF), Color(0x120E1626)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? selectedBorderColor : unselectedBorderColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? selectedIconColor : Colors.white70,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? selectedTextColor
                        : ProMaxTokens.textPrimary,
                    fontSize: 12,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: selected
                    ? selectedIconColor
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsAccountActionButton extends StatelessWidget {
  const _SettingsAccountActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDanger
        ? const Color(0xFFFF9EA1)
        : ProMaxTokens.iconPrimary;
    final titleColor = isDanger
        ? const Color(0xFFFFD7D8)
        : ProMaxTokens.textPrimary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap(),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDanger
                  ? const [Color(0x38FF6E76), Color(0x1B2A1216)]
                  : const [Color(0x2D8ED0FF), Color(0x150D1A2C)],
            ),
            border: Border.all(
              color: isDanger
                  ? const Color(0x66FF6E76)
                  : ProMaxTokens.inputBorderFocused.withValues(alpha: 0.70),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ProMaxTokens.textSecondary.withValues(alpha: 0.92),
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ProMaxGlassCardWidget(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: ProMaxTokens.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 8,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
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
