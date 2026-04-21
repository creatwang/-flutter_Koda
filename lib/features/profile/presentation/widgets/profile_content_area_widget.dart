import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/profile/models/profile_content_section.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_favorites_section_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_my_customers_section_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_order_center_section_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_section_header_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_settings_panel_widget.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

class ProfileContentAreaWidget extends StatelessWidget {
  const ProfileContentAreaWidget({
    super.key,
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
    required this.isSwitchingAccount,
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
  final bool isSwitchingAccount;
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
        isEnabled: !isLoadingUserInfo && !isSigningOut && !isSwitchingAccount,
        onPressed: () async => onRefreshSettings(),
      );
    } else {
      sectionHeaderTrailing = null;
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
                    ProfileSettingsPanelWidget(
                      viewInsetsBottom: viewInsetsBottom,
                      fullNameController: fullNameController,
                      oldPasswordController: oldPasswordController,
                      newPasswordController: newPasswordController,
                      confirmPasswordController: confirmPasswordController,
                      showValidation: showValidation,
                      validationMessage: validationMessage,
                      onSaveSettings: onSaveSettings,
                      onOpenSwitchSiteSheet: onOpenSwitchSiteSheet,
                      showSwitchSiteEntry: showSwitchSiteEntry,
                      hasMainAccountSnapshot: hasMainAccountSnapshot,
                      onSignOut: onSignOut,
                      onSwitchAccount: onSwitchAccount,
                      isSigningOut: isSigningOut,
                      isSwitchingAccount: isSwitchingAccount,
                      isSavingSettings: isSavingSettings,
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
