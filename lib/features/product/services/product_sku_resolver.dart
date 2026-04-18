import 'package:collection/collection.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';

/// 与前端 SKU 选择页一致的解析逻辑：
/// 1）按各维选中 `spec` 自上而下拼接 `_index`
/// 2）在售 `product_sub` 中先按 `_index` + `pid` 交集命中
/// 3）未命中则按 `pid` 交集 ∩ 在售兜底
class ProductSkuResolveResult {
  const ProductSkuResolveResult({
    required this.sub,
    required this.indexStr,
    required this.pids,
    this.via,
  });

  final ProductSub? sub;
  final String indexStr;
  final List<int> pids;

  /// `index`：索引命中；`pidFallback`：交集兜底
  final String? via;
}

/// 纯函数 SKU 解析，供详情页等复用。
abstract final class ProductSkuResolver {
  static bool isSubOnSale(ProductSub sub) => sub.status == 1;

  /// 自上而下拼接 `spec` → `_index`
  static String buildIndexFromSelection(
    Product product,
    List<Options> selectedOptions,
  ) {
    final rows = product.specValue ?? const <SpecValue>[];
    final parts = <String>[];
    for (var i = 0; i < rows.length && i < selectedOptions.length; i++) {
      final spec = selectedOptions[i].spec?.trim() ?? '';
      if (spec.isNotEmpty) parts.add(spec);
    }
    return parts.join('_');
  }

  /// 各维 `option.pid` 交集
  static List<int> intersectPids(List<Options> selectedOptions) {
    if (selectedOptions.isEmpty) return const <int>[];
    final first = selectedOptions.first.pid;
    if (first == null || first.isEmpty) return const <int>[];
    var acc = List<int>.from(first);
    for (var i = 1; i < selectedOptions.length; i++) {
      final p = selectedOptions[i].pid;
      if (p == null || p.isEmpty) return const <int>[];
      acc = acc.where(p.contains).toList(growable: false);
    }
    return acc;
  }

  static ProductSub? findSubByIndex(
    String indexStr,
    List<Options> selectedOptions,
    List<Product> productList,
    int activeProductId,
  ) {
    final pids = intersectPids(selectedOptions);
    final candidates = <ProductSub>[];
    for (final product in productList) {
      for (final sub in product.productSub ?? const <ProductSub>[]) {
        if (!isSubOnSale(sub)) continue;
        if (sub.sIndex != indexStr) continue;
        final pid = sub.pid;
        if (pids.isNotEmpty && pid != null && !pids.contains(pid)) {
          continue;
        }
        candidates.add(sub);
      }
    }
    if (candidates.isEmpty) return null;
    return candidates.firstWhereOrNull((s) => s.pid == activeProductId) ??
        candidates.first;
  }

  static ProductSub? findSubByPidInIntersection(
    List<Options> selectedOptions,
    int? preferPid,
    List<Product> productList,
  ) {
    final pids = intersectPids(selectedOptions);
    if (pids.isEmpty) return null;
    ProductSub? first;
    ProductSub? preferred;
    for (final product in productList) {
      for (final sub in product.productSub ?? const <ProductSub>[]) {
        if (!isSubOnSale(sub)) continue;
        final pid = sub.pid;
        if (pid == null || !pids.contains(pid)) continue;
        first ??= sub;
        if (preferPid != null && pid == preferPid) preferred = sub;
      }
    }
    return preferred ?? first;
  }

  static ProductSkuResolveResult resolveSubForSelection(
    Product product,
    List<Options> selectedOptions,
    List<Product> productList,
    int activeProductId,
  ) {
    final indexStr = buildIndexFromSelection(product, selectedOptions);
    final pids = intersectPids(selectedOptions);
    var sub = findSubByIndex(
      indexStr,
      selectedOptions,
      productList,
      activeProductId,
    );
    String? via = sub != null ? 'index' : null;
    if (sub == null) {
      sub = findSubByPidInIntersection(
        selectedOptions,
        activeProductId,
        productList,
      );
      if (sub != null) via = 'pidFallback';
    }
    return ProductSkuResolveResult(
      sub: sub,
      indexStr: indexStr,
      pids: pids,
      via: via,
    );
  }

  static List<Options> selectionFromSub(Product product, ProductSub sub) {
    final parts = (sub.sIndex ?? '')
        .split('_')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final rows = product.specValue ?? const <SpecValue>[];
    return List<Options>.generate(rows.length, (i) {
      final opts = rows[i].options ?? const <Options>[];
      if (opts.isEmpty) {
        throw StateError('Spec row has no options: ${rows[i].name}');
      }
      final token = i < parts.length ? parts[i] : null;
      return opts.firstWhereOrNull((o) => o.spec == token) ?? opts.first;
    }, growable: false);
  }

  /// 切换主产品时：优先 `pid == 产品 id` 的在售 sub，否则第一条在售，否则每维首项
  static List<Options> getDefaultSelection(Product product) {
    final subs = (product.productSub ?? const <ProductSub>[])
        .where(isSubOnSale)
        .toList(growable: false);
    final sub =
        subs.firstWhereOrNull((s) => s.pid == product.id) ?? subs.firstOrNull;
    final rows = product.specValue ?? const <SpecValue>[];
    if (sub == null) {
      return rows
          .map((r) => (r.options ?? const <Options>[]).firstOrNull)
          .whereType<Options>()
          .toList(growable: false);
    }
    return selectionFromSub(product, sub);
  }

  static Product? productById(List<Product> variants, int id) =>
      variants.firstWhereOrNull((p) => p.id == id);
}
