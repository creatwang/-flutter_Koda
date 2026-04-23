import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/auth/services/site_info_services.dart';
import 'package:george_pick_mate/features/product/services/product_sku_cart_helpers.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_mall_text_field_dialog.dart';

/// 站点 `product_addcart_space == 1` 时收集用户输入的 `space`。
/// 取消返回 `null`，确定返回非空字符串。
Future<String?> showCartSpaceInputDialog(BuildContext context) {
  final l10n = context.l10n;
  return showMallTextFieldDialog(
    context: context,
    title: l10n.cartSpaceDialogTitle,
    subtitle:
        'One short tag for this cart line — keeps picks organized.',
    hintText: l10n.cartSpaceDialogHint,
    cancelLabel: 'Cancel',
    confirmLabel: 'Add',
    barrierDismissible: false,
  );
}

/// 站点要求时弹窗输入 `space`；否则返回 [kCartSpaceDefault]。
/// 用户取消（仅在选择性弹窗场景）返回 `null`。
Future<String?> resolveSpaceForCartAdd(BuildContext context) async {
  final site = await readSiteInfoFromLocal();
  if (!context.mounted) return null;
  if (site?.productAddcartSpace == 1) {
    return showCartSpaceInputDialog(context);
  }
  return kCartSpaceDefault;
}
