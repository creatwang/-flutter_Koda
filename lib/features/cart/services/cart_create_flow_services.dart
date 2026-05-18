import 'package:george_pick_mate/features/cart/models/create_cart_item_result.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';

/// 将 [CreateCartItemResult] 转为侧滑/弹窗提交用的 `bool`（成功为 `true`）。
///
/// `100000` 时展示 [showCartUnorderedItemsConfirmDialog] 后返回 `false`。
Future<bool> resolveCreateCartItemSubmitSuccess(
  CreateCartItemResult result,
) async {
  switch (result) {
    case CreateCartItemSuccess():
      return true;
    case CreateCartItemUnordered(:final message):
      await showCartUnorderedItemsConfirmDialog(message);
      return false;
    case CreateCartItemFailure():
      return false;
  }
}
