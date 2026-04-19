import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/main_user_providers.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/customer_account_providers.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_favorites_section_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_my_customers_section_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_order_center_section_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_section_header_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/store_customer_common_password_bottom_sheet.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/store_customer_form_bottom_sheet.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/switch_site_bottom_sheet.dart';
import 'package:groe_app_pad/features/cart/controllers/cart_providers.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/shared/widgets/home_main_content_slot_widget.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_glass_card_widget.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_input_field_widget.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

enum ProfileContentSection { settings, myCustomers, orderCenter, favorites }

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
    this.showSwitchSiteEntry = false,
  });

  /// 由首页「Profile」入口长按 10s 切换；为 `true` 时在设置中展示切换站点按钮。
  final bool showSwitchSiteEntry;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  ProfileContentSection _currentSection = ProfileContentSection.settings;
  ProfileOrderTab _currentOrderTab = ProfileOrderTab.my;
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
  bool _isSigningOut = false;
  bool _hasHydratedName = false;

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
    setState(() {
      _settingsErrorMessage = null;
      _isSigningOut = true;
    });
    final result = await ref
        .read(sessionControllerProvider.notifier)
        .signOutWithRemoteLogout();
    if (!mounted) return;
    setState(() => _isSigningOut = false);
    result.when(
      success: (_) => context.go(AppRoutes.login),
      failure: (exception) {
        setState(() => _settingsErrorMessage = exception.message);
      },
    );
  }

  Future<void> _onSwitchAccount() async {
    final result = await ref
        .read(sessionControllerProvider.notifier)
        .switchBackToMainUser();
    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Switched to main account.')),
        );
        context.go(AppRoutes.home);
      },
      failure: (exception) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(exception.message)));
      },
    );
  }

  Future<void> _onOpenSwitchSiteSheet() async {
    await showSwitchSiteBottomSheet(parentContext: context, ref: ref);
  }

  @override
  Widget build(BuildContext context) {
    final userInfoState = ref.watch(profileUserInfoProvider);
    final favoriteState = ref.watch(favoriteProductsProvider);
    final favoriteData = favoriteState.asData?.value;
    final favoriteCount =
        favoriteData?.totalCount ?? favoriteData?.items.length ?? 0;
    final cartBadgeCount = ref.watch(cartBadgeCountProvider);
    final userName = userInfoState.asData?.value.name ?? '';
    final avatarUrl = userInfoState.asData?.value.avatar ?? '';
    final userId = userInfoState.asData?.value.id?.toInt();
    final canViewCustomerOrders =
        userInfoState.asData?.value.isAuthAccount == true;
    final visibleMenus = _buildProfileSidebarMenus(
      isSalesRep: canViewCustomerOrders,
    );
    final contentSection = _resolveProfileVisibleSection(
      visibleMenus,
      _currentSection,
    );
    if (contentSection != _currentSection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentSection = contentSection);
        }
      });
    }
    final selectedMeta = visibleMenus.firstWhere(
      (item) => item.section == contentSection,
      orElse: () => visibleMenus.first,
    );
    final mainUserAsync = ref.watch(mainUserInfoProvider);
    final hasMainAccountSnapshot = mainUserAsync.maybeWhen(
      data: (u) => u != null,
      orElse: () => false,
    );
    if (!_hasHydratedName && userName.trim().isNotEmpty) {
      _fullNameController.text = userName;
      _hasHydratedName = true;
    }
    return HomeMainContentSlot(
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
              cartBadgeCount: cartBadgeCount,
              currentSection: contentSection,
              menus: visibleMenus,
              onSectionChanged: (next) {
                setState(() => _currentSection = next);
                if (next == ProfileContentSection.favorites) {
                  ref.read(favoriteProductsProvider.notifier).refresh();
                }
                if (next == ProfileContentSection.myCustomers) {
                  ref.read(storeCustomersProvider.notifier).refresh();
                }
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: double.infinity,
              child: _ProfileContentArea(
                currentSection: contentSection,
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
                onOpenSwitchSiteSheet: _onOpenSwitchSiteSheet,
                showSwitchSiteEntry: widget.showSwitchSiteEntry,
                hasMainAccountSnapshot: hasMainAccountSnapshot,
                isSigningOut: _isSigningOut,
                isSavingSettings: _isSavingSettings,
                isLoadingUserInfo:
                    contentSection == ProfileContentSection.settings &&
                    userInfoState.isLoading,
                canViewCustomerOrders: canViewCustomerOrders,
                currentOrderTab: _currentOrderTab,
                onOrderTabChanged: (nextTab) {
                  if (_currentOrderTab == nextTab) return;
                  setState(() => _currentOrderTab = nextTab);
                },
                onMyCustomersAddCustomer: canViewCustomerOrders
                    ? () => showStoreCustomerFormBottomSheet(
                          context: context,
                          ref: ref,
                          mode: StoreCustomerSheetMode.create,
                        )
                    : null,
                onMyCustomersSetCommandPassword: canViewCustomerOrders
                    ? () async {
                        await showStoreCustomerCommonPasswordBottomSheet(
                          context: context,
                          ref: ref,
                        );
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSidebar extends StatelessWidget {
  const _ProfileSidebar({
    required this.avatarUrl,
    required this.profileName,
    required this.profileId,
    required this.favoriteCount,
    required this.cartBadgeCount,
    required this.currentSection,
    required this.menus,
    required this.onSectionChanged,
  });

  final String avatarUrl;
  final String profileName;
  final int? profileId;
  final int favoriteCount;
  final int cartBadgeCount;
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
                          Expanded(
                            child: _StatTile(
                              value: '$cartBadgeCount',
                              label: 'CART NUM',
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
    required this.onOpenSwitchSiteSheet,
    required this.showSwitchSiteEntry,
    required this.hasMainAccountSnapshot,
    required this.isSigningOut,
    required this.isSavingSettings,
    required this.isLoadingUserInfo,
    required this.canViewCustomerOrders,
    required this.currentOrderTab,
    required this.onOrderTabChanged,
    this.onMyCustomersAddCustomer,
    this.onMyCustomersSetCommandPassword,
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
  final Future<void> Function() onOpenSwitchSiteSheet;
  final bool showSwitchSiteEntry;
  final bool hasMainAccountSnapshot;
  final bool isSigningOut;
  final bool isSavingSettings;
  final bool isLoadingUserInfo;
  final bool canViewCustomerOrders;
  final ProfileOrderTab currentOrderTab;
  final ValueChanged<ProfileOrderTab> onOrderTabChanged;
  final VoidCallback? onMyCustomersAddCustomer;
  final VoidCallback? onMyCustomersSetCommandPassword;

  @override
  Widget build(BuildContext context) {
    final isSettings = currentSection == ProfileContentSection.settings;
    final isOrderCenter = currentSection == ProfileContentSection.orderCenter;
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

    final Widget? sectionHeaderTrailing;
    if (isOrderCenter && canViewCustomerOrders) {
      sectionHeaderTrailing = Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ProfileOrderTabSwitcherWidget(
          currentTab: currentOrderTab,
          onTabChanged: onOrderTabChanged,
        ),
      );
    } else if (currentSection == ProfileContentSection.myCustomers &&
        onMyCustomersAddCustomer != null &&
        onMyCustomersSetCommandPassword != null) {
      sectionHeaderTrailing = Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ProfileMyCustomersHeaderActionsWidget(
          onAddCustomer: onMyCustomersAddCustomer!,
          onSetCommandPassword: onMyCustomersSetCommandPassword!,
        ),
      );
    } else if (isSettings) {
      sectionHeaderTrailing = ProfileSectionHeaderRefreshButton(
        isEnabled: !isLoadingUserInfo && !isSigningOut,
        onPressed: () async => onRefreshSettings(),
      );
    } else {
      sectionHeaderTrailing = null;
    }

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
        borderRadius: BorderRadius.circular(ProMaxTokens.radiusPanel),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSectionHeaderWidget(
              title: title,
              trailing: sectionHeaderTrailing,
            ),
            if (isSettings) ...[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.hardEdge,
                  children: <Widget>[
                    SingleChildScrollView(
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
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
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
                                                    color: const Color(
                                                      0x26FF6E76,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
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
                                                          color: Color(
                                                            0xFFFFA9AD,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Expanded(
                                                          child: SelectableText.rich(
                                                            TextSpan(
                                                              text:
                                                                  validationMessage!,
                                                              style: const TextStyle(
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
                                        onPressed:
                                            isSavingSettings || isSigningOut
                                            ? null
                                            : () => onSaveSettings(),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(120, 44),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        child: isSavingSettings
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
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
                                            onTap: () =>
                                                onOpenSwitchSiteSheet(),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Ink(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: <Color>[
                                                    const Color(0x55F4C77A),
                                                    const Color(0x28FFC9A8),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color: const Color(
                                                    0x88F4C77A,
                                                  ),
                                                ),
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                    color: const Color(
                                                      0x33F4C77A,
                                                    ),
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
                                    color: ProMaxTokens.textSecondary
                                        .withValues(alpha: 0.92),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                if (hasMainAccountSnapshot)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SettingsAccountActionButton(
                                          icon: Icons.switch_account_rounded,
                                          title: 'Switch Account',
                                          subtitle:
                                              'Switch back to original account',
                                          onTap: onSwitchAccount,
                                          isEnabled: !isSigningOut,
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
                                          isLoading: isSigningOut,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SettingsAccountActionButton(
                                          icon: Icons.logout_rounded,
                                          title: 'Sign Out',
                                          subtitle: 'Exit current account',
                                          isDanger: true,
                                          onTap: onSignOut,
                                          isLoading: isSigningOut,
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
                    if (isLoadingUserInfo)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: switch (currentSection) {
                  ProfileContentSection.favorites =>
                    const ProfileFavoritesSectionWidget(),
                  ProfileContentSection.myCustomers =>
                    const ProfileMyCustomersSectionWidget(),
                  ProfileContentSection.orderCenter =>
                    ProfileOrderCenterSectionWidget(
                      canViewCustomerOrders: canViewCustomerOrders,
                      currentTab: currentOrderTab,
                    ),
                  _ => AppEmptyView(
                    message: '$title is empty',
                    width: 130,
                    height: 130,
                  ),
                },
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
    this.isLoading = false,
    this.isEnabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;
  final bool isDanger;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading;
    final iconColor = isDanger
        ? const Color(0xFFFF9EA1)
        : ProMaxTokens.iconPrimary;
    final titleColor = isDanger
        ? const Color(0xFFFFD7D8)
        : ProMaxTokens.textPrimary;
    return Opacity(
      opacity: (!isEnabled && !isLoading) ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canTap
              ? () async {
                  await onTap();
                }
              : null,
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
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 18),
                    if (isLoading) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ],
                ),
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

List<_ProfileSectionMeta> _buildProfileSidebarMenus({
  required bool isSalesRep,
}) {
  return <_ProfileSectionMeta>[
    const _ProfileSectionMeta(
      section: ProfileContentSection.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
    if (isSalesRep)
      const _ProfileSectionMeta(
        section: ProfileContentSection.myCustomers,
        label: 'My Customers',
        icon: Icons.groups_outlined,
      ),
    const _ProfileSectionMeta(
      section: ProfileContentSection.orderCenter,
      label: 'Order Center',
      icon: Icons.notifications_none_outlined,
    ),
    const _ProfileSectionMeta(
      section: ProfileContentSection.favorites,
      label: 'Favorites',
      icon: Icons.favorite_border,
    ),
  ];
}

ProfileContentSection _resolveProfileVisibleSection(
  List<_ProfileSectionMeta> menus,
  ProfileContentSection current,
) {
  if (menus.any((m) => m.section == current)) return current;
  return ProfileContentSection.settings;
}
