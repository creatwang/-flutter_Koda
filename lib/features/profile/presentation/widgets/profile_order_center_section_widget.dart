import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_order_providers.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_product_order_list_widget.dart';

enum ProfileOrderTab { my, customer }

class ProfileOrderCenterSectionWidget extends ConsumerWidget {
  const ProfileOrderCenterSectionWidget({
    required this.canViewCustomerOrders,
    required this.currentTab,
    super.key,
  });

  final bool canViewCustomerOrders;
  final ProfileOrderTab currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canShowCustomerTab = canViewCustomerOrders;
    final effectiveTab = canShowCustomerTab
        ? currentTab
        : ProfileOrderTab.my;
    final state = effectiveTab == ProfileOrderTab.my
        ? ref.watch(profileMyOrderListProvider)
        : ref.watch(profileCustomerOrderListProvider);
    Future<void> refreshCurrentTab() async {
      if (effectiveTab == ProfileOrderTab.my) {
        await ref.read(profileMyOrderListProvider.notifier).refresh();
        return;
      }
      await ref.read(profileCustomerOrderListProvider.notifier).refresh();
    }

    void loadMoreCurrentTab() {
      if (effectiveTab == ProfileOrderTab.my) {
        ref.read(profileMyOrderListProvider.notifier).loadMore();
        return;
      }
      ref.read(profileCustomerOrderListProvider.notifier).loadMore();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ProfileProductOrderListWidget(
            asyncState: state,
            onRefresh: refreshCurrentTab,
            onLoadMore: loadMoreCurrentTab,
            showUserInfo: effectiveTab == ProfileOrderTab.customer,
          ),
        ),
      ],
    );
  }
}

class ProfileOrderTabSwitcherWidget extends StatelessWidget {
  const ProfileOrderTabSwitcherWidget({
    required this.currentTab,
    required this.onTabChanged,
    super.key,
  });

  final ProfileOrderTab currentTab;
  final ValueChanged<ProfileOrderTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OrderTabButton(
            isSelected: currentTab == ProfileOrderTab.my,
            label: 'My',
            onTap: () => onTabChanged(ProfileOrderTab.my),
          ),
          const SizedBox(width: 4),
          _OrderTabButton(
            isSelected: currentTab == ProfileOrderTab.customer,
            label: 'Customer',
            onTap: () => onTabChanged(ProfileOrderTab.customer),
          ),
        ],
      ),
    );
  }
}

class _OrderTabButton extends StatelessWidget {
  const _OrderTabButton({
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
