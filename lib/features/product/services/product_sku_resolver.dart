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

class ProductSkuTapSelectionResult {
  const ProductSkuTapSelectionResult({
    required this.selectedProductId,
    required this.skuSelectedOptions,
    required this.skuSelectionOwnerId,
  });

  final int? selectedProductId;
  final List<Options> skuSelectedOptions;
  final int? skuSelectionOwnerId;
}

final class _SpecContainmentCandidate {
  const _SpecContainmentCandidate({
    required this.idxStr,
    required this.matchCount,
    required this.isExact,
    required this.specMap,
  });

  final String idxStr;
  final int matchCount;
  final bool isExact;
  final Map<String, String> specMap;
}

/// 纯函数 SKU 解析，供详情页等复用。
abstract final class ProductSkuResolver {
  static bool isSubOnSale(ProductSub sub) => sub.status == 1;

  static String _safe(String? value) => (value ?? '').trim();

  /// 扫码 / 详情组合索引（如 `a0_b0`）拆成各维 `spec` token。
  static List<String> splitSpecIndexTokens(String? index) => _safe(index)
      .split('_')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  /// 将当前变体下全部 [Options] 以 [Options.spec] 为 key 平铺，便于按 token 取值。
  static Map<String, Options> buildSpecOptionsLookup(Product product) {
    final out = <String, Options>{};
    for (final group in product.specValue ?? const <SpecValue>[]) {
      for (final opt in group.options ?? const <Options>[]) {
        final spec = _safe(opt.spec);
        if (spec.isEmpty) continue;
        out[spec] = opt;
      }
    }
    return out;
  }

  /// 优先 `_index`（[ProductSub.sIndex]），否则回退 `index`（与扫码 query 对齐）。
  static String compositeSpecIndex(ProductSub sub) {
    final s = _safe(sub.sIndex);
    if (s.isNotEmpty) return s;
    return _safe(sub.index);
  }

  static String _rowAttrIndex(SpecValue row, {Options? fallbackOpt}) {
    final byRow = _safe(row.attrIndex);
    if (byRow.isNotEmpty) return byRow;
    final byOpt = _safe(fallbackOpt?.attrIndex);
    if (byOpt.isNotEmpty) return byOpt;
    final spec = _safe(fallbackOpt?.spec);
    if (spec.isNotEmpty) return spec.substring(0, 1);
    return '';
  }

  static Map<String, String> _buildSpecToAttr(Product product) {
    final map = <String, String>{};
    for (final group in product.specValue ?? const <SpecValue>[]) {
      final attr = _rowAttrIndex(group);
      for (final opt in group.options ?? const <Options>[]) {
        final spec = _safe(opt.spec);
        if (spec.isEmpty) continue;
        if (attr.isNotEmpty) {
          map[spec] = attr;
          continue;
        }
        map[spec] = spec.substring(0, 1);
      }
    }
    return map;
  }

  static Map<String, String> specByAttrFromSelection(
    Product product,
    List<Options> selectedOptions,
  ) {
    final rows = product.specValue ?? const <SpecValue>[];
    final map = <String, String>{};
    for (var i = 0; i < rows.length; i++) {
      if (i >= selectedOptions.length) break;
      final row = rows[i];
      final opt = selectedOptions[i];
      final spec = _safe(opt.spec);
      if (spec.isEmpty) continue;
      final key = _rowAttrIndex(row, fallbackOpt: opt);
      if (key.isEmpty) continue;
      map[key] = spec;
    }
    return map;
  }

  static Map<String, String> _specMapFromSub(Product product, ProductSub sub) {
    final specToAttr = _buildSpecToAttr(product);
    final map = <String, String>{};
    for (final spec in splitSpecIndexTokens(sub.sIndex)) {
      final attr = specToAttr[spec] ?? spec.substring(0, 1);
      if (map.containsKey(attr)) continue;
      map[attr] = spec;
    }
    return map;
  }

  static String buildIndexFromSpecByAttr(Map<String, String> specByAttr) {
    final items =
        specByAttr.values
            .map(_safe)
            .where((e) => e.isNotEmpty)
            .toList(growable: false)
          ..sort();
    return items.join('_');
  }

  static ProductSub? _findSubByIndex(Product product, String index) {
    final target = _safe(index);
    if (target.isEmpty) return null;
    return (product.productSub ?? const <ProductSub>[]).firstWhereOrNull(
      (sub) => _safe(sub.sIndex) == target,
    );
  }

  static Product? _productById(List<Product> variants, int? productId) {
    if (productId == null) return null;
    return variants.firstWhereOrNull((p) => p.id == productId);
  }

  static Map<String, String> _defaultSpecByAttr(Product product) =>
      specByAttrFromSelection(product, getDefaultSelection(product));

  /// 自上而下拼接 `spec`，按字典序归一化为 `_index`
  static String buildIndexFromSelection(
    Product product,
    List<Options> selectedOptions,
  ) => buildIndexFromSpecByAttr(
    specByAttrFromSelection(product, selectedOptions),
  );

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
    final specByAttr = _specMapFromSub(product, sub);
    return selectionFromSpecByAttr(product, specByAttr);
  }

  static List<Options> selectionFromSpecByAttr(
    Product product,
    Map<String, String> specByAttr,
  ) {
    final rows = product.specValue ?? const <SpecValue>[];
    final out = <Options>[];
    for (final row in rows) {
      final opts = row.options ?? const <Options>[];
      if (opts.isEmpty) {
        continue;
      }
      final attr = _rowAttrIndex(row);
      final token = specByAttr[attr];
      out.add(opts.firstWhereOrNull((o) => o.spec == token) ?? opts.first);
    }
    return out;
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

  static bool isSpecUnavailable({
    required Product currentProduct,
    required int currentProductId,
    required String specKey,
  }) {
    final normalizedSpec = _safe(specKey);
    if (normalizedSpec.isEmpty) return true;
    if ((currentProduct.isAttrProduct ?? 0) == 0) return false;

    final validRows = (currentProduct.productSub ?? const <ProductSub>[])
        .where(
          (row) => row.pid == currentProductId && _safe(row.sIndex).isNotEmpty,
        )
        .toList(growable: false);
    if (validRows.isEmpty) return true;

    final containing = validRows
        .where((row) => splitSpecIndexTokens(row.sIndex).contains(normalizedSpec))
        .toList(growable: false);
    if (containing.isEmpty) return true;
    return !containing.any((row) => row.status == 1);
  }

  static List<_SpecContainmentCandidate> _getSpecContainments({
    required Product product,
    required String specKey,
    required Map<String, String> selectedSpecByAttr,
  }) {
    final targetSpec = _safe(specKey);
    if (targetSpec.isEmpty) return const <_SpecContainmentCandidate>[];

    final selectedSpecs = selectedSpecByAttr.values
        .map(_safe)
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    final currentIndex = buildIndexFromSpecByAttr(selectedSpecByAttr);
    final availRows = (product.productSub ?? const <ProductSub>[])
        .where(
          (row) =>
              row.status == 1 &&
              _safe(row.sIndex).isNotEmpty &&
              splitSpecIndexTokens(row.sIndex).contains(targetSpec),
        )
        .toList(growable: false);

    final candidates = availRows
        .map((row) {
          final specs = splitSpecIndexTokens(row.sIndex);
          final idx = _safe(row.sIndex);
          final matchCount = selectedSpecs.where(specs.contains).length;
          final isExact = currentIndex.isNotEmpty && currentIndex == idx;
          return _SpecContainmentCandidate(
            idxStr: idx,
            matchCount: matchCount,
            isExact: isExact,
            specMap: _specMapFromSub(product, row),
          );
        })
        .toList(growable: false);

    candidates.sort((a, b) {
      if (a.isExact && !b.isExact) return -1;
      if (!a.isExact && b.isExact) return 1;
      if (b.matchCount != a.matchCount) {
        return b.matchCount.compareTo(a.matchCount);
      }
      return a.idxStr.compareTo(b.idxStr);
    });
    return candidates;
  }

  static ProductSkuTapSelectionResult? applySpecTapSelection({
    required int rowIndex,
    required Options opt,
    required Product selected,
    required List<Product> variants,
    required List<Options>? skuSelectedOptions,
    required int? skuSelectionOwnerId,
    required int? selectedProductId,
  }) {
    final rows = selected.specValue ?? const <SpecValue>[];
    if (rowIndex < 0 || rowIndex >= rows.length) return null;
    final row = rows[rowIndex];
    final hit = (row.options ?? const <Options>[]).firstWhereOrNull(
      (o) => o.spec == opt.spec,
    );
    if (hit == null) return null;

    final base =
        (skuSelectedOptions != null &&
            skuSelectedOptions.length == rows.length &&
            skuSelectionOwnerId == selected.id)
        ? List<Options>.from(skuSelectedOptions)
        : List<Options>.from(getDefaultSelection(selected));
    base[rowIndex] = hit;

    var currentProduct = _productById(
      variants,
      selectedProductId ?? selected.id,
    );
    currentProduct ??= selected;

    final clickedSpec = _safe(hit.spec);
    final clickedAttr = _rowAttrIndex(row, fallbackOpt: hit);
    var selectedSpecByAttr = specByAttrFromSelection(currentProduct, base);
    if (clickedAttr.isNotEmpty && clickedSpec.isNotEmpty) {
      selectedSpecByAttr[clickedAttr] = clickedSpec;
    }

    // 1) 点击后先尝试按当前组合反推当前产品。
    var currentSub = _findSubByIndex(
      currentProduct,
      buildIndexFromSpecByAttr(selectedSpecByAttr),
    );
    final subPid = currentSub?.pid;
    final bySubPid = _productById(variants, subPid);
    if (bySubPid != null) {
      currentProduct = bySubPid;
      selectedSpecByAttr = specByAttrFromSelection(
        currentProduct,
        selectionFromSpecByAttr(currentProduct, selectedSpecByAttr),
      );
    }

    // 2) 组合不存在时：回退到当前点击项 pid[0] 对应产品并重置默认组合。
    currentSub = _findSubByIndex(
      currentProduct,
      buildIndexFromSpecByAttr(selectedSpecByAttr),
    );
    if (currentSub == null) {
      final fallbackPid = (hit.pid ?? const <int>[]).firstOrNull;
      final fallbackProduct = _productById(variants, fallbackPid);
      if (fallbackProduct != null) {
        currentProduct = fallbackProduct;
      }
      selectedSpecByAttr = _defaultSpecByAttr(currentProduct);
    }

    // 3) 命中禁用组合时：挑选同规格下最优可售组合。
    final currentIndex = buildIndexFromSpecByAttr(selectedSpecByAttr);
    final disabledIndexes = (currentProduct.productSub ?? const <ProductSub>[])
        .where((row) => row.status == 0)
        .map((row) => _safe(row.sIndex))
        .where((idx) => idx.isNotEmpty)
        .toSet();
    final isAttrProduct = (currentProduct.isAttrProduct ?? 0) == 1;
    if (isAttrProduct && disabledIndexes.contains(currentIndex)) {
      final matches = _getSpecContainments(
        product: currentProduct,
        specKey: clickedSpec,
        selectedSpecByAttr: selectedSpecByAttr,
      );
      if (matches.isNotEmpty) {
        selectedSpecByAttr = Map<String, String>.from(matches.first.specMap);
      } else {
        selectedSpecByAttr = _defaultSpecByAttr(currentProduct);
      }
    }

    final normalized = selectionFromSpecByAttr(
      currentProduct,
      selectedSpecByAttr,
    );
    return ProductSkuTapSelectionResult(
      selectedProductId: currentProduct.id ?? selectedProductId ?? selected.id,
      skuSelectedOptions: normalized,
      skuSelectionOwnerId: currentProduct.id,
    );
  }
}
