import 'dart:async';

import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/product/controllers/product_detail_controller.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/services/product_sku_resolver.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_filled_button.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_quantity_control.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';

class ProductDetailInfoPanel extends StatelessWidget {
  const ProductDetailInfoPanel({
    super.key,
    required this.detail,
    required this.selected,
    required this.selectedId,
    required this.skuRowSelection,
    required this.skuResolved,
    required this.variants,
    required this.productNum,
    required this.onSelectVariant,
    required this.onApplySpecOption,
    required this.onDecrementQty,
    required this.onIncrementQty,
    required this.onBuyNow,
    required this.onAddToCart,
    required this.isBuyNowSubmitting,
    required this.isAddToCartSubmitting,
  });

  final ProductDetailDto detail;
  final Product selected;
  final int selectedId;
  final List<Options> skuRowSelection;
  final ProductSkuResolveResult skuResolved;
  final List<Product> variants;
  final int productNum;
  final void Function(int pid) onSelectVariant;
  final void Function(int rowIndex, Options opt) onApplySpecOption;
  final VoidCallback onDecrementQty;
  final VoidCallback onIncrementQty;
  final Future<void> Function() onBuyNow;
  final Future<void> Function() onAddToCart;
  final bool isBuyNowSubmitting;
  final bool isAddToCartSubmitting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = selected.name ?? detail.name ?? '--';
    final productCode = (selected.uniqid ?? detail.uniqid ?? '');
    final hasMatchedSku = skuResolved.sub != null;
    final unitPrice = ProductDetailController.unitPriceFromResolvedSub(
      skuResolved.sub,
    );
    final canAddToCart = hasMatchedSku && unitPrice > 0;
    final totalPrice = unitPrice * productNum;
    final specRows = selected.specValue ?? const <SpecValue>[];
    final unit = (selected.unit ?? detail.unit ?? '').trim();
    final quantityText =
        unit.isEmpty ? '$productNum' : '$productNum $unit';
    final isQtyBusy = isBuyNowSubmitting || isAddToCartSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productCode,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 36,
            height: 1.05,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasMatchedSku)
              Text(
                '\$${double.parse(totalPrice.toStringAsFixed(2)).toString()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Text(
                'no product',
                style: TextStyle(
                  color: Colors.red.shade200,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRODUCT:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: variants
                            .map((product) {
                              final pid = product.id;
                              final isSelected =
                                  pid != null && pid == selectedId;
                              final display =
                                  product.name ?? product.nameCn ?? '--';
                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: pid == null
                                    ? null
                                    : () => onSelectVariant(pid),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withValues(
                                              alpha: 0.25,
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    display,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                ...specRows.asMap().entries.map((entry) {
                  final rowIndex = entry.key;
                  final group = entry.value;
                  final options = group.options ?? const <Options>[];
                  if (options.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (group.name ?? '').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: options
                              .map((option) {
                                final spec = option.spec ?? '';
                                final isSelected =
                                    rowIndex < skuRowSelection.length &&
                                    (skuRowSelection[rowIndex].spec ?? '') ==
                                        spec;
                                final isUnavailable =
                                    ProductSkuResolver.isSpecUnavailable(
                                      currentProduct: selected,
                                      currentProductId: selectedId,
                                      specKey: spec,
                                    );
                                final isDisabled = isUnavailable && !isSelected;
                                final display =
                                    option.name ?? option.nameCn ?? '--';
                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: isDisabled
                                      ? null
                                      : () =>
                                            onApplySpecOption(rowIndex, option),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : isDisabled
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.white.withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : isDisabled
                                            ? Colors.white.withValues(
                                                alpha: 0.12,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.25,
                                              ),
                                      ),
                                    ),
                                    child: Text(
                                      display,
                                      style: TextStyle(
                                        color: isDisabled
                                            ? Colors.white54
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ProductDetailGeorgeQty(
          productNum: productNum,
          quantityText: quantityText,
          isBusy: isQtyBusy,
          onDecrement: onDecrementQty,
          onIncrement: onIncrementQty,
        ),
        const SizedBox(height: 10),
        GeorgeFilledButton(
          width: double.infinity,
          minimumSize: const Size(0, 46),
          borderRadius: 5,
          onPressed: canAddToCart && !isBuyNowSubmitting
              ? () async {
                  await onBuyNow();
                }
              : null,
          isLoading: isBuyNowSubmitting,
          child: Text(
            l10n.productDetailBuyNow,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        GeorgeFilledButton(
          width: double.infinity,
          minimumSize: const Size(0, 46),
          borderRadius: 5,
          backgroundColor: const Color.fromRGBO(200, 200, 200, 1),
          foregroundColor: const Color.fromRGBO(58, 72, 91, 1),
          loadingIndicatorColor: const Color.fromRGBO(58, 72, 91, 1),
          onPressed: canAddToCart && !isAddToCartSubmitting
              ? () async {
                  await onAddToCart();
                }
              : null,
          isLoading: isAddToCartSubmitting,
          child: Text(
            context.l10n.addToCart,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// 与购物车一致的 [GeorgeQuantityControl] 大号档位，含长按连调。
class _ProductDetailGeorgeQty extends StatefulWidget {
  const _ProductDetailGeorgeQty({
    required this.productNum,
    required this.quantityText,
    required this.isBusy,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int productNum;
  final String quantityText;
  final bool isBusy;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  State<_ProductDetailGeorgeQty> createState() =>
      _ProductDetailGeorgeQtyState();
}

class _ProductDetailGeorgeQtyState extends State<_ProductDetailGeorgeQty> {
  Timer? _quantityPressTimer;

  @override
  void dispose() {
    _stopContinuousAdjust();
    super.dispose();
  }

  void _stopContinuousAdjust() {
    _quantityPressTimer?.cancel();
    _quantityPressTimer = null;
  }

  void _startContinuousAdjust(int delta) {
    if (widget.isBusy) return;
    _stopContinuousAdjust();
    _quantityPressTimer = Timer.periodic(const Duration(milliseconds: 220), (
      _,
    ) {
      if (delta < 0 && widget.productNum <= 1) {
        _stopContinuousAdjust();
        return;
      }
      if (delta < 0) {
        widget.onDecrement();
      } else {
        widget.onIncrement();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeorgeQuantityControl(
      quantityText: widget.quantityText,
      size: QuantityControl.large,
      isDecreaseEnabled: !widget.isBusy && widget.productNum > 1,
      isIncreaseEnabled: !widget.isBusy,
      onDecreaseTap: () async => widget.onDecrement(),
      onIncreaseTap: () async => widget.onIncrement(),
      onDecreaseLongPressStart: () => _startContinuousAdjust(-1),
      onDecreaseLongPressEnd: _stopContinuousAdjust,
      onIncreaseLongPressStart: () => _startContinuousAdjust(1),
      onIncreaseLongPressEnd: _stopContinuousAdjust,
    );
  }
}
