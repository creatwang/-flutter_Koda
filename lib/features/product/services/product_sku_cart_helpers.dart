import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';

/// 加购/改规格时 `space` 默认值（站点 `product_addcart_space == 0` 时使用）。
const String kCartSpaceDefault = 'default';

abstract final class ProductSkuCartHelpers {
  /// `sub_name`：当前选中 `product_sub` 展示名 + 各维已选 `options` 展示名，逗号拼接。
  static String buildCartSubName({
    required ProductSub sub,
    required List<Options> skuRowSelection,
  }) {
    final subLabel = (sub.nameCn ?? sub.name ?? '').trim();
    final optionLabels = skuRowSelection
        .map((o) => (o.nameCn ?? o.name ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    return <String>[subLabel, ...optionLabels]
        .where((s) => s.isNotEmpty)
        .join(',');
  }

  /// 接口 `sub_index` 对应 `product_sub.index`（非 `_index`）。
  static String subIndexForApi(ProductSub sub) => (sub.index ?? '').trim();

  /// 接口 `_index` 对应 `product_sub.s_index`，缺失时回退 `sub_index`。
  static String sIndexForApi(ProductSub sub) {
    final sIndex = (sub.sIndex ?? '').trim();
    if (sIndex.isNotEmpty) return sIndex;
    return subIndexForApi(sub);
  }
}
