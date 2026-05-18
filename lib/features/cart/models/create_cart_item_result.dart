/// 加购接口在 controller 层的统一结果（不含 UI）。
sealed class CreateCartItemResult {
  const CreateCartItemResult();
}

final class CreateCartItemSuccess extends CreateCartItemResult {
  const CreateCartItemSuccess();
}

/// 业务码 `100000`：购物车仍有未下单商品。
final class CreateCartItemUnordered extends CreateCartItemResult {
  const CreateCartItemUnordered(this.message);

  final String message;
}

/// 其它失败（全局 Toast 已在 controller 中展示）。
final class CreateCartItemFailure extends CreateCartItemResult {
  const CreateCartItemFailure();
}
