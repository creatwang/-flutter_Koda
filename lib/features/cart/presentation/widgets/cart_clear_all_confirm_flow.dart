import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/models/cart_list_dto.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_george_confirm_dialog.dart';

/// 购物车 / 预订单共用的「Clear」确认与执行（选中则删选中，否则清空全部）。
Future<void> runCartClearAllConfirmFlow({
  required BuildContext context,
  required List<CartListDto> currentGroups,
  required CartController cartNotifier,
  void Function(bool isBusy)? onBusy,
}) async {
  final l10n = context.l10n;
  final selectedIds = currentGroups
      .expand((group) => group.items)
      .expand((site) => site.cart.items)
      .expand((space) => space.list)
      .where((item) => item.isSelected)
      .map((item) => item.id)
      .toSet()
      .toList(growable: false);
  final hasSelectedItems = selectedIds.isNotEmpty;

  final confirmed = await showGeorgeConfirmDialog(
    context: context,
    title: hasSelectedItems
        ? l10n.cartRemoveSelectedTitle
        : l10n.cartClearShortlistTitle,
    message: hasSelectedItems
        ? l10n.cartRemoveSelectedMessage(selectedIds.length)
        : l10n.cartClearShortlistMessage,
    confirmLabel: hasSelectedItems ? l10n.commonRemove : l10n.commonClearAll,
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
    if (ok) {
      showGlobalSnackBar(
        hasSelectedItems
            ? l10n.cartSelectedLinesRemoved
            : l10n.cartShortlistCleared,
      );
    } else {
      showGlobalErrorMessage(
        hasSelectedItems
            ? l10n.cartRemoveSelectedFailed
            : l10n.cartClearFailed,
      );
    }
  } finally {
    if (context.mounted) {
      onBusy?.call(false);
    }
  }
}
