import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/cart/models/cart_list_dto.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/services/product_sku_cart_helpers.dart';
import 'package:george_pick_mate/features/product/services/product_sku_resolver.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_filled_button.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';

const Color _kSkuDrawerChipIdle = Color(0xFF2E2E2E);
const Color _kSkuDrawerQtyMinus = Color(0xFF404040);
const Color _kSkuDrawerQtyPlus = Color(0xFFFFD233);

/// 侧滑 SKU 加购 / 改规格：与详情页一致的解析与 [sub_name] 组装。
enum ProductSkuCartSheetMode { addToCart, changeSpec }

/// 侧滑内提交加购/改规格。
///
/// [sheetContext]：侧滑路由上的 [BuildContext]，用于再叠 `showDialog`。
/// 勿用外层列表页 context，否则易出现「只有遮罩、面板不显示」。
typedef ProductSkuCartSubmitCallback =
    Future<bool> Function(
      BuildContext sheetContext,
      ProductSkuCartSubmitPayload payload,
    );

class ProductSkuCartSubmitPayload {
  const ProductSkuCartSubmitPayload({
    required this.apiProductId,
    required this.subIndex,
    required this.productNum,
    required this.subName,
  });

  /// 对应接口 `product_id`（命中 `product_sub.pid`）。
  final int apiProductId;

  /// 对应接口 `sub_index`（`product_sub.index`）。
  final String subIndex;
  final int productNum;
  final String subName;
}

Future<bool> presentProductSkuCartSideSheet({
  required BuildContext context,
  required ProductDetailDto detail,
  bool showMainImage = false,
  CartProductDto? cartLine,
  required ProductSkuCartSheetMode mode,
  required ProductSkuCartSubmitCallback onSubmit,
}) async {
  final rootNav = Navigator.of(context, rootNavigator: true);
  final barrierLabel = MaterialLocalizations.of(
    context,
  ).modalBarrierDismissLabel;
  final result = await rootNav.push<bool>(
    PageRouteBuilder<bool>(
      opaque: false,
      barrierDismissible: true,
      barrierLabel: barrierLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return _ProductSkuCartSideSheetScaffold(
          animation: animation,
          detail: detail,
          showMainImage: showMainImage,
          cartLine: cartLine,
          mode: mode,
          onSubmit: onSubmit,
        );
      },
      transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    ),
  );
  return result == true;
}

class _ProductSkuCartSideSheetScaffold extends StatelessWidget {
  const _ProductSkuCartSideSheetScaffold({
    required this.animation,
    required this.detail,
    required this.showMainImage,
    required this.cartLine,
    required this.mode,
    required this.onSubmit,
  });

  final Animation<double> animation;
  final ProductDetailDto detail;
  final bool showMainImage;
  final CartProductDto? cartLine;
  final ProductSkuCartSheetMode mode;
  final ProductSkuCartSubmitCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = (media.size.width * 0.30).clamp(360.0, 520.0);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(false),
            child: const SizedBox.expand(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: Material(
                elevation: 24,
                color: const Color(0xFF151515),
                shadowColor: Colors.black,
                child: SizedBox(
                  width: width,
                  height: media.size.height,
                  child: _ProductSkuCartSideSheetBody(
                    detail: detail,
                    showMainImage: showMainImage,
                    cartLine: cartLine,
                    mode: mode,
                    onSubmit: onSubmit,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSkuCartSideSheetBody extends StatefulWidget {
  const _ProductSkuCartSideSheetBody({
    required this.detail,
    required this.showMainImage,
    required this.cartLine,
    required this.mode,
    required this.onSubmit,
  });

  final ProductDetailDto detail;
  final bool showMainImage;
  final CartProductDto? cartLine;
  final ProductSkuCartSheetMode mode;
  final ProductSkuCartSubmitCallback onSubmit;

  @override
  State<_ProductSkuCartSideSheetBody> createState() =>
      _ProductSkuCartSideSheetBodyState();
}

class _ProductSkuCartSideSheetBodyState
    extends State<_ProductSkuCartSideSheetBody> {
  static const Color _kPanelBg = Color(0xFF151515);

  int? _selectedProductId;
  List<Options>? _skuSelectedOptions;
  int? _skuSelectionOwnerId;
  int _productNum = 1;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bootstrapSku();
  }

  void _bootstrapSku() {
    final detail = widget.detail;
    final variants = detail.product ?? const <Product>[];
    if (variants.isEmpty) return;

    final line = widget.cartLine;
    if (line != null) {
      final hit = _matchCartLineToSelection(variants, line);
      if (hit != null) {
        _selectedProductId = hit.$1;
        _skuSelectedOptions = hit.$2;
        _skuSelectionOwnerId = hit.$3;
        return;
      }
    }

    final fallbackId = detail.id ?? variants.first.id;
    _selectedProductId = fallbackId;
    final sel =
        variants.firstWhereOrNull((e) => e.id == _selectedProductId) ??
        variants.first;
    _skuSelectedOptions = ProductSkuResolver.getDefaultSelection(sel);
    _skuSelectionOwnerId = sel.id;
  }

  /// (`selectedVariantId`, selection, ownerId)
  (int, List<Options>, int?)? _matchCartLineToSelection(
    List<Product> variants,
    CartProductDto line,
  ) {
    for (final p in variants) {
      final pid = p.id;
      if (pid == null) continue;
      for (final s in p.productSub ?? const <ProductSub>[]) {
        if (!ProductSkuResolver.isSubOnSale(s)) continue;
        if ((s.index ?? '').trim() != line.subIndex.trim()) continue;
        if (s.pid != line.productId) continue;
        return (pid, ProductSkuResolver.selectionFromSub(p, s), p.id);
      }
    }
    for (final p in variants) {
      final pid = p.id;
      if (pid == null) continue;
      for (final s in p.productSub ?? const <ProductSub>[]) {
        if (!ProductSkuResolver.isSubOnSale(s)) continue;
        if ((s.index ?? '').trim() != line.subIndex.trim()) continue;
        return (pid, ProductSkuResolver.selectionFromSub(p, s), p.id);
      }
    }
    return null;
  }

  void _selectVariantProduct(int pid, List<Product> variants) {
    if (_selectedProductId == pid) return;
    final product = variants.firstWhereOrNull((e) => e.id == pid);
    if (product == null) return;
    setState(() {
      _selectedProductId = pid;
      _skuSelectedOptions = ProductSkuResolver.getDefaultSelection(product);
      _skuSelectionOwnerId = product.id;
      _errorMessage = null;
    });
  }

  void _applySpecOption(
    int rowIndex,
    Options opt,
    Product selected,
    List<Product> variants,
  ) {
    final next = ProductSkuResolver.applySpecTapSelection(
      rowIndex: rowIndex,
      opt: opt,
      selected: selected,
      variants: variants,
      skuSelectedOptions: _skuSelectedOptions,
      skuSelectionOwnerId: _skuSelectionOwnerId,
      selectedProductId: _selectedProductId,
    );
    if (next == null) return;

    setState(() {
      _selectedProductId = next.selectedProductId;
      _skuSelectedOptions = next.skuSelectedOptions;
      _skuSelectionOwnerId = next.skuSelectionOwnerId;
      _errorMessage = null;
    });
  }

  String? _thumbUrl(ProductDetailDto detail, Product selected) {
    final a = selected.mainImage?.trim();
    if (a != null && a.isNotEmpty) return a;
    final b = detail.mainImage?.trim();
    if (b != null && b.isNotEmpty) return b;
    final variants = detail.product ?? const <Product>[];
    final v = variants.firstOrNull?.mainImage?.trim();
    if (v != null && v.isNotEmpty) return v;
    return null;
  }

  Future<void> _onPrimaryPressed(
    BuildContext context,
    Product selected,
    List<Product> variants,
    List<Options> skuRowSelection,
    ProductSkuResolveResult skuResolved,
  ) async {
    final sub = skuResolved.sub;
    if (sub == null || sub.pid == null) {
      setState(() => _errorMessage = context.l10n.cartNoMatchedSku);
      return;
    }
    if (widget.mode == ProductSkuCartSheetMode.addToCart) {
      final salesPrice = sub.salesPrice ?? 0;
      if (salesPrice <= 0) {
        setState(
          () => _errorMessage = context.l10n.cartAddBlockedZeroSalesPrice,
        );
        return;
      }
    }
    final subIndex = ProductSkuCartHelpers.subIndexForApi(sub);
    if (subIndex.isEmpty) {
      setState(() => _errorMessage = context.l10n.cartNoMatchedSku);
      return;
    }
    final subName = ProductSkuCartHelpers.buildCartSubName(
      sub: sub,
      skuRowSelection: skuRowSelection,
    );
    final qty = widget.mode == ProductSkuCartSheetMode.changeSpec
        ? (widget.cartLine?.productNum ?? 1)
        : _productNum;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final ok = await widget.onSubmit(
      context,
      ProductSkuCartSubmitPayload(
        apiProductId: sub.pid!,
        subIndex: subIndex,
        productNum: qty,
        subName: subName,
      ),
    );
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = widget.detail;
    final variants = detail.product ?? const <Product>[];
    if (variants.isEmpty) {
      return ColoredBox(
        color: _kPanelBg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.productDetailVariantsEmpty,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final fallbackId = detail.id ?? variants.first.id ?? 0;
    final currentId = _selectedProductId ?? fallbackId;
    final selected =
        variants.firstWhereOrNull((e) => e.id == currentId) ?? variants.first;
    final selectedId = selected.id ?? fallbackId;

    final specRows = selected.specValue ?? const <SpecValue>[];
    final skuRowSelection =
        (_skuSelectedOptions != null &&
            _skuSelectedOptions!.length == specRows.length &&
            _skuSelectionOwnerId == selected.id)
        ? _skuSelectedOptions!
        : ProductSkuResolver.getDefaultSelection(selected);

    final skuResolved = ProductSkuResolver.resolveSubForSelection(
      selected,
      skuRowSelection,
      variants,
      selectedId,
    );
    final hasMatchedSku = skuResolved.sub != null;
    final unitPrice = skuResolved.sub?.salesPrice ?? 0.0;
    // 加购需有价；改规格仅要求命中 SKU（数量沿用购物车行）。
    final canSubmitPrimary = hasMatchedSku &&
        (widget.mode == ProductSkuCartSheetMode.changeSpec || unitPrice > 0);
    final thumbUrl = _thumbUrl(detail, selected);
    final title =
        selected.nameCn ?? selected.name ?? detail.nameCn ?? detail.name ?? '';
    final primaryLabel = widget.mode == ProductSkuCartSheetMode.changeSpec
        ? l10n.cartConfirmChangeSpec
        : l10n.cartConfirmAdd;

    // 改规格：数量沿用购物车行，不在侧栏展示加减控件。
    final Widget? qtyControls =
        widget.mode == ProductSkuCartSheetMode.addToCart
        ? Row(
            children: [
              _QtySquareButton(
                background: _kSkuDrawerQtyMinus,
                onTap: _isSubmitting || _productNum <= 1
                    ? null
                    : () => setState(() => _productNum -= 1),
                child: const Icon(Icons.remove, color: Colors.white, size: 10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$_productNum',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _QtySquareButton(
                background: _kSkuDrawerQtyPlus,
                onTap: _isSubmitting
                    ? null
                    : () => setState(() => _productNum += 1),
                child: const Icon(Icons.add, color: Colors.black, size: 10),
              ),
            ],
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: _DrawerThumb(url: thumbUrl),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${unitPrice.toString()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                          if (qtyControls != null) ...[
                            const SizedBox(height: 6),
                            qtyControls,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (variants.length > 1) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n.cartSkuDrawerProductLine,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...variants.map((product) {
                    final pid = product.id;
                    final isSelected = pid != null && pid == selectedId;
                    final display = product.name ?? product.nameCn ?? '--';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DrawerOptionTile(
                        label: display,
                        isSelected: isSelected,
                        isDisabled: false,
                        fullWidth: true,
                        onTap: pid == null
                            ? null
                            : () => _selectVariantProduct(pid, variants),
                      ),
                    );
                  }),
                ],
                ...specRows.asMap().entries.map((entry) {
                  final rowIndex = entry.key;
                  final group = entry.value;
                  final options = group.options ?? const <Options>[];
                  if (options.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final label = (group.name ?? '').trim().isEmpty
                      ? l10n.cartSkuDrawerProductLine
                      : (group.name ?? '').trim();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        options.length > 3
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: options
                                    .map((option) {
                                      final spec = option.spec ?? '';
                                      final isSelected =
                                          rowIndex < skuRowSelection.length &&
                                          (skuRowSelection[rowIndex].spec ??
                                                  '') ==
                                              spec;
                                      final isUnavailable =
                                          ProductSkuResolver.isSpecUnavailable(
                                            currentProduct: selected,
                                            currentProductId: selectedId,
                                            specKey: spec,
                                          );
                                      final isDisabled =
                                          isUnavailable && !isSelected;
                                      final display =
                                          option.name ?? option.nameCn ?? '--';
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: _DrawerOptionTile(
                                          label: display,
                                          isSelected: isSelected,
                                          isDisabled: isDisabled,
                                          fullWidth: true,
                                          onTap: isDisabled
                                              ? null
                                              : () => _applySpecOption(
                                                  rowIndex,
                                                  option,
                                                  selected,
                                                  variants,
                                                ),
                                        ),
                                      );
                                    })
                                    .toList(growable: false),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: options
                                    .map((option) {
                                      final spec = option.spec ?? '';
                                      final isSelected =
                                          rowIndex < skuRowSelection.length &&
                                          (skuRowSelection[rowIndex].spec ??
                                                  '') ==
                                              spec;
                                      final isUnavailable =
                                          ProductSkuResolver.isSpecUnavailable(
                                            currentProduct: selected,
                                            currentProductId: selectedId,
                                            specKey: spec,
                                          );
                                      final isDisabled =
                                          isUnavailable && !isSelected;
                                      final display =
                                          option.name ?? option.nameCn ?? '--';
                                      return _DrawerOptionTile(
                                        label: display,
                                        isSelected: isSelected,
                                        isDisabled: isDisabled,
                                        fullWidth: false,
                                        onTap: isDisabled
                                            ? null
                                            : () => _applySpecOption(
                                                rowIndex,
                                                option,
                                                selected,
                                                variants,
                                              ),
                                      );
                                    })
                                    .toList(growable: false),
                              ),
                      ],
                    ),
                  );
                }),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  SelectableText.rich(
                    TextSpan(
                      text: _errorMessage,
                      style: const TextStyle(
                        color: Color(0xFFFF8A80),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          child: Row(
            children: [
              Expanded(
                child: GeorgeFilledButton(
                  shape: const StadiumBorder(),
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: Text(
                    l10n.cartSkuDrawerClose,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: GeorgeFilledButton(
                  shape: const StadiumBorder(),
                  elevation: 0,
                  side: const BorderSide(color: Colors.white, width: 1.2),
                  disabledBackgroundColor: const Color(0xFF3A3A3A),
                  disabledForegroundColor: Colors.white38,
                  onPressed:
                      (!canSubmitPrimary || _isSubmitting)
                      ? null
                      : () => _onPrimaryPressed(
                          context,
                          selected,
                          variants,
                          skuRowSelection,
                          skuResolved,
                        ),
                  isLoading: _isSubmitting,
                  loadingIndicatorColor: Colors.white,
                  child: Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawerThumb extends StatelessWidget {
  const _DrawerThumb({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: _kSkuDrawerChipIdle,
        child: url == null || url!.isEmpty
            ? const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white38,
                  size: 32,
                ),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 32,
                  ),
                ),
              ),
      ),
    );
  }
}

class _QtySquareButton extends StatelessWidget {
  const _QtySquareButton({
    required this.background,
    required this.child,
    this.onTap,
  });

  final Color background;
  final Widget child;
  final VoidCallback? onTap;

  static const double _kSize = 16;

  @override
  Widget build(BuildContext context) {
    final inner = SizedBox(
      width: _kSize,
      height: _kSize,
      child: Center(child: child),
    );
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? inner
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: inner,
            ),
    );
  }
}

class _DrawerOptionTile extends StatelessWidget {
  const _DrawerOptionTile({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.fullWidth,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDisabled;
  final bool fullWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? Colors.white
        : isDisabled
        ? _kSkuDrawerChipIdle.withValues(alpha: 0.55)
        : _kSkuDrawerChipIdle;
    final fg = isSelected
        ? Colors.black
        : isDisabled
        ? Colors.white54
        : Colors.white;
    final tile = Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: fullWidth ? 8 : 4,
            horizontal: fullWidth ? 16 : 14,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: tile);
    }
    return tile;
  }
}
