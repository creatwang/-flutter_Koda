import 'package:george_pick_mate/features/cart/models/create_cart_item_result.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';

/// 将 [CreateCartItemResult] 转为侧滑/弹窗提交结果。
///
/// `100000` 时展示 [showCartUnorderedItemsConfirmDialog] 后返回 `null`。
///
/// 返回值：成功时返回 `smId`，失败返回 `null`。
Future<int?> resolveCreateCartItemSubmitSuccess(
  CreateCartItemResult result,
) async {
  switch (result) {
    case CreateCartItemSuccess(:final smId):
      return smId;
    case CreateCartItemUnordered(:final message):
      await showCartUnorderedItemsConfirmDialog(message);
      return null;
    case CreateCartItemFailure():
      return null;
  }
}

String buildAddToCartSuccessMessage({
  required AppLocalizations l10n,
  required String productTitle,
  required int smId,
}) {
  if (smId != 0) {
    return l10n.productAddedToPreOrder(productTitle);
  }
  return l10n.productAddedToCartSuccess(productTitle);
}
