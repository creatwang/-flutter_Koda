import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/controllers/main_user_providers.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/profile/controllers/profile_page_controller.dart';
import 'package:george_pick_mate/features/profile/controllers/profile_providers.dart';
import 'package:george_pick_mate/features/profile/controllers/customer_account_providers.dart';
import 'package:george_pick_mate/features/profile/models/profile_content_section.dart';
import 'package:george_pick_mate/features/profile/models/profile_section_meta.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/profile_content_area_widget.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/profile_order_center_section_widget.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/profile_sidebar_widget.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/store_customer_common_password_bottom_sheet.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/store_customer_form_bottom_sheet.dart';
import 'package:george_pick_mate/features/profile/presentation/widgets/switch_site_bottom_sheet.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/shared/widgets/home_main_content_slot_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.showSwitchSiteEntry = false});

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
  bool _isSwitchingAccount = false;
  bool _hasHydratedName = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSaveSettings() async {
    setState(() => _showSettingsValidation = true);
    final validationError = ProfilePageController.validateSettingsForm(
      fullName: _fullNameController.text,
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (validationError != null) {
      setState(() => _settingsErrorMessage = validationError);
      return;
    }

    setState(() {
      _settingsErrorMessage = null;
      _isSavingSettings = true;
    });
    final result = await ProfilePageController.updateUserInfo(
      ref,
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
    await ProfilePageController.refreshProfile(ref);
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
    final result = await ProfilePageController.signOutWithRemoteLogout(ref);
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
    setState(() => _isSwitchingAccount = true);
    try {
      final result = await ProfilePageController.switchBackToMainUser(ref);
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
    } finally {
      if (mounted) setState(() => _isSwitchingAccount = false);
    }
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
    final listCartBadge = ref.watch(cartListBadgeCountProvider);
    final profileServerCartNum = ref.watch(profileCartServerNumProvider);
    final cartBadgeCount = profileServerCartNum ?? listCartBadge;
    final userName = userInfoState.asData?.value.name ?? '';
    final avatarUrl = userInfoState.asData?.value.avatar ?? '';
    final userId = userInfoState.asData?.value.id?.toInt();
    final profileSiteId = ref
        .watch(sessionControllerProvider)
        .asData
        ?.value
        .companyId;
    final canViewCustomerOrders =
        userInfoState.asData?.value.isAuthAccount == true;
    final visibleMenus = buildProfileSidebarMenus(
      isSalesRep: canViewCustomerOrders,
    );
    final contentSection = resolveProfileVisibleSection(
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
            child: ProfileSidebarWidget(
              avatarUrl: avatarUrl,
              profileName: userName,
              profileId: userId,
              profileSiteId: profileSiteId,
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
              child: ProfileContentAreaWidget(
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
                isSwitchingAccount: _isSwitchingAccount,
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
