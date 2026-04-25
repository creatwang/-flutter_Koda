import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/models/cart_list_dto.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_mall_confirm_dialog.dart';

/// 购物车 / 预订单共用的「Clear」确认与执行（选中则删选中，否则清空全部）。
Future<void> runCartClearAllConfirmFlow({
  required BuildContext context,
  required List<CartListDto> currentGroups,
  required CartController cartNotifier,
  void Function(bool isBusy)? onBusy,
}) async {
  final selectedIds = currentGroups
      .expand((group) => group.items)
      .expand((site) => site.cart.items)
      .expand((space) => space.list)
      .where((item) => item.isSelected)
      .map((item) => item.id)
      .toSet()
      .toList(growable: false);
  final hasSelectedItems = selectedIds.isNotEmpty;

  final confirmed = await showMallConfirmDialog(
    context: context,
    title: hasSelectedItems
        ? 'Remove selected lines?'
        : 'Clear entire shortlist?',
    message: hasSelectedItems
        ? '${selectedIds.length} selected lines will be removed from '
              'your shortlist.'
        : 'This clears all cart lines currently loaded for your sites.',
    confirmLabel: hasSelectedItems ? 'Remove' : 'Clear all',
    icon: hasSelectedItems
        ? Icons.delete_sweep_rounded
        : Icons.cleaning_services_rounded,
    accentColor: hasSelectedItems
        ? const Color(0xFFFF7B6B)
        : const Color(0xFFFFB86B),
  );
  if (!context.mounted || confirmed != true) return;

  onBusy?.call(true);
  try {
    final ok = hasSelectedItems
        ? await cartNotifier.removeSelectedItems()
        : await cartNotifier.clearAllSitesCart();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (hasSelectedItems ? '已删除选中商品' : '购物车已清空')
              : (hasSelectedItems ? '删除选中失败，请稍后再试' : '清空失败，请稍后再试'),
        ),
      ),
    );
  } finally {
    if (context.mounted) {
      onBusy?.call(false);
    }
  }
}
