import 'package:collection/collection.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/services/product_sku_resolver.dart';
import 'package:george_pick_mate/features/product/services/product_services.dart';

/// 详情页一次 build 内解析出的选中 SKU、画廊等（无 UI、无 Riverpod）。
final class ProductDetailResolvedSelection {
  const ProductDetailResolvedSelection({
    required this.selected,
    required this.selectedId,
    required this.skuRowSelection,
    required this.skuResolved,
    required this.galleryImages,
  });

  final Product selected;
  final int selectedId;
  final List<Options> skuRowSelection;
  final ProductSkuResolveResult skuResolved;
  final List<String> galleryImages;

  /// [variants] 为空时返回 `null`，由页面展示错误态。
  static ProductDetailResolvedSelection? tryResolve({
    required ProductDetailDto detail,
    required int pageProductId,
    int? selectedProductId,
    List<Options>? skuSelectedOptions,
    int? skuSelectionOwnerId,
  }) {
    final variants = detail.product ?? const <Product>[];
    if (variants.isEmpty) return null;

    final fallbackId = detail.id ?? variants.first.id ?? pageProductId;
    final currentId = selectedProductId ?? fallbackId;
    final selected =
        variants.firstWhereOrNull((e) => e.id == currentId) ?? variants.first;
    final selectedId = selected.id ?? fallbackId;

    final specRows = selected.specValue ?? const <SpecValue>[];
    final skuRowSelection =
        (skuSelectedOptions != null &&
            skuSelectedOptions.length == specRows.length &&
            skuSelectionOwnerId == selected.id)
        ? skuSelectedOptions
        : ProductSkuResolver.getDefaultSelection(selected);

    final skuResolved = ProductSkuResolver.resolveSubForSelection(
      selected,
      skuRowSelection,
      variants,
      selectedId,
    );
    final galleryImages = ProductDetailController.buildGalleryImages(
      detail: detail,
      selected: selected,
    );

    return ProductDetailResolvedSelection(
      selected: selected,
      selectedId: selectedId,
      skuRowSelection: skuRowSelection,
      skuResolved: skuResolved,
      galleryImages: galleryImages,
    );
  }
}

/// 与 SKU 相关的局部状态片段（写入 State 的 `_selectedProductId` 等）。
final class ProductDetailSkuPickResult {
  const ProductDetailSkuPickResult({
    required this.selectedProductId,
    required this.skuSelectedOptions,
    required this.skuSelectionOwnerId,
  });

  final int? selectedProductId;
  final List<Options> skuSelectedOptions;
  final int? skuSelectionOwnerId;
}

final class ProductDetailScanResult {
  const ProductDetailScanResult({
    required this.detail,
    required this.selected,
    required this.selectedId,
    required this.skuRowSelection,
    required this.selectedSub,
  });

  final ProductDetailDto detail;
  final Product selected;
  final int selectedId;
  final List<Options> skuRowSelection;
  final ProductSub selectedSub;
}

/// 商品详情页：纯编排 / 数据整理（无网络、无 Dio）。
abstract final class ProductDetailController {
  /// 画廊：选中 SKU 的 [Product.subImages] → [ProductDetailDto.subImages] →
  /// 仅主图 `[detail.mainImage]`。
  static List<String> buildGalleryImages({
    required ProductDetailDto detail,
    required Product selected,
  }) {
    final selectedImages = (selected.subImages ?? const <String>[])
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (selectedImages.isNotEmpty) return selectedImages;

    final detailImages = (detail.subImages ?? const <String>[])
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (detailImages.isNotEmpty) return detailImages;

    final detailMainImage = detail.mainImage?.trim();
    if (detailMainImage != null && detailMainImage.isNotEmpty) {
      return <String>[detailMainImage];
    }

    return const <String>[];
  }

  /// 单价仅取自当前解析命中的 [ProductSub.salesPrice]（与接口 `sales_price` 一致）。
  static double unitPriceFromResolvedSub(ProductSub? resolvedSub) =>
      resolvedSub?.salesPrice ?? 0;

  /// 首次拉到详情后的默认 SKU 选择（假定 [detail.product] 非空）。
  static ProductDetailSkuPickResult bootstrapSkuPickFromDetail({
    required ProductDetailDto detail,
    required int pageProductId,
    int? selectedProductId,
  }) {
    final variants = detail.product ?? const <Product>[];
    final fallbackId = detail.id ?? variants.first.id ?? pageProductId;
    final effectivePid = selectedProductId ?? fallbackId;
    final sel =
        variants.firstWhereOrNull((e) => e.id == effectivePid) ??
        variants.first;
    return ProductDetailSkuPickResult(
      selectedProductId: selectedProductId ?? fallbackId,
      skuSelectedOptions: ProductSkuResolver.getDefaultSelection(sel),
      skuSelectionOwnerId: sel.id,
    );
  }

  /// 切换「PRODUCT」行变体；与当前相同或找不到时返回 `null`。
  static ProductDetailSkuPickResult? pickVariantOrNull({
    required int pid,
    required int? currentSelectedProductId,
    required List<Product> variants,
  }) {
    if (currentSelectedProductId == pid) return null;
    final product = variants.firstWhereOrNull((e) => e.id == pid);
    if (product == null) return null;
    return ProductDetailSkuPickResult(
      selectedProductId: pid,
      skuSelectedOptions: ProductSkuResolver.getDefaultSelection(product),
      skuSelectionOwnerId: product.id,
    );
  }

  /// 规格维度点击后的新 SKU 选择；无效点击返回 `null`。
  static ProductDetailSkuPickResult? applySpecOptionPickOrNull({
    required int rowIndex,
    required Options opt,
    required Product selected,
    required List<Product> variants,
    required List<Options>? skuSelectedOptions,
    required int? skuSelectionOwnerId,
    required int? selectedProductId,
  }) {
    final next = ProductSkuResolver.applySpecTapSelection(
      rowIndex: rowIndex,
      opt: opt,
      selected: selected,
      variants: variants,
      skuSelectedOptions: skuSelectedOptions,
      skuSelectionOwnerId: skuSelectionOwnerId,
      selectedProductId: selectedProductId,
    );
    if (next == null) return null;
    return ProductDetailSkuPickResult(
      selectedProductId: next.selectedProductId,
      skuSelectedOptions: next.skuSelectedOptions,
      skuSelectionOwnerId: next.skuSelectionOwnerId,
    );
  }

  /// 缩略图列表：若需滚动以露出 [index]，返回目标 `offset`；否则 `null`。
  static double? targetThumbScrollOffsetOrNull({
    required int index,
    required double currentOffset,
    required double viewportHeight,
    required double minScrollExtent,
    required double maxScrollExtent,
    double itemHeight = 74,
    double itemGap = 10,
  }) {
    final itemExtent = itemHeight + itemGap;
    final itemTop = index * itemExtent;
    final itemBottom = itemTop + itemHeight;
    final viewportTop = currentOffset;
    final viewportBottom = viewportTop + viewportHeight;

    double? targetOffset;
    if (itemTop < viewportTop) {
      targetOffset = itemTop;
    } else if (itemBottom > viewportBottom) {
      targetOffset = itemBottom - viewportHeight;
    }

    if (targetOffset == null) return null;
    return targetOffset.clamp(minScrollExtent, maxScrollExtent);
  }

  static Map<String, String> queryToObj(String? queryStr) {
    if (queryStr == null || queryStr.isEmpty) {
      return <String, String>{};
    }
    var iterable = queryStr;
    if (iterable.contains('?')) {
      iterable = iterable.split('?').last;
    }
    final acc = <String, String>{};
    for (final curr in iterable.split('&')) {
      if (curr.isEmpty) continue;
      final eq = curr.indexOf('=');
      final key = eq == -1
          ? Uri.decodeQueryComponent(curr)
          : Uri.decodeQueryComponent(curr.substring(0, eq));
      final value = eq == -1
          ? ''
          : Uri.decodeQueryComponent(curr.substring(eq + 1));
      acc[key] = value;
    }
    return acc;
  }

  /// 对应 JS 的 formatProdSub 函数
  /// 对应 JS 的 formatProdSub 函数逻辑
  /// 通过 id 筛选 product，并从中寻找 index 匹配的 productSub
  static ProductSub? formatProdSub({
    required ProductDetailDto detail,
    int? id,
    String? index,
  }) {
    if (id == null) return null;

    // 1. 过滤出 id 匹配的 product 列表
    final productList = detail.product?.where((item) => item.id == id);

    if (productList == null || productList.isEmpty) return null;

    // 2. 使用 expand 平铺所有 productSub，并直接查找匹配 index 的项
    // firstWhereOrNull 需要 import 'package:collection/collection.dart'; (你文件中已包含)
    return productList
        .expand((item) => item.productSub ?? <ProductSub>[])
        .firstWhereOrNull((sub) => sub.index == index);
  }

  static ProductDetailScanResult? resolveScanResultOrNull({
    required ProductDetailDto detail,
    required int productId,
    String? subIndex,
  }) {
    final variants = detail.product ?? const <Product>[];
    if (variants.isEmpty) return null;
    final selected =
        variants.firstWhereOrNull((item) => item.id == productId) ??
        variants.first;
    final selectedId = selected.id ?? productId;
    final normalizedIndex = (subIndex ?? '').trim();
    ProductSub? selectedSub;
    if (normalizedIndex.isNotEmpty) {
      selectedSub = (selected.productSub ?? const <ProductSub>[])
          .firstWhereOrNull((sub) => sub.index == normalizedIndex);
    }
    selectedSub ??= formatProdSub(
      detail: detail,
      id: selectedId,
      index: normalizedIndex,
    );
    if (selectedSub == null) return null;
    final skuRowSelection = ProductSkuResolver.selectionFromSub(
      selected,
      selectedSub,
    );
    return ProductDetailScanResult(
      detail: detail,
      selected: selected,
      selectedId: selectedId,
      skuRowSelection: skuRowSelection,
      selectedSub: selectedSub,
    );
  }

  static Future<ProductDetailScanResult?> formatProductDetailScanInfo(
    String? queryStr,
  ) async {
    final query = queryToObj(queryStr);
    final idText = query['id']?.trim();
    if (idText == null || idText.isEmpty) return null;
    final id = int.tryParse(idText);
    if (id == null) return null;
    final result = await fetchProductDetailService(id);
    final payload = result.getOrThrow();
    return resolveScanResultOrNull(
      detail: payload,
      productId: id,
      subIndex: query['index'],
    );
  }
}
