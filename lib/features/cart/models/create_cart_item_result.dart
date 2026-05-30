/// 加购接口在 controller 层的统一结果（不含 UI）。
sealed class CreateCartItemResult {
  const CreateCartItemResult();
}

final class CreateCartItemSuccess extends CreateCartItemResult {
  const CreateCartItemSuccess({required this.smId});

  /// 后端返回的 `sm_id`；`0` 表示加入购物车，非 `0` 表示进入预订单链路。
  final int smId;
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
