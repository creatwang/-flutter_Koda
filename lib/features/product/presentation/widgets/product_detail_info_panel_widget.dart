import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/product/controllers/product_detail_controller.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_detail_qty_adjust_button_widget.dart';
import 'package:groe_app_pad/features/product/services/product_sku_resolver.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

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
            fontSize: 40,
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
                '\$${totalPrice.toString()}',
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
        Row(
          children: [
            const SizedBox(width: 10),
            ProductDetailQtyAdjustButton(
              icon: Icons.remove,
              onTap: productNum <= 1 ? null : onDecrementQty,
            ),
            Container(
              width: 46,
              alignment: Alignment.center,
              child: Text(
                '$productNum',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ProductDetailQtyAdjustButton(
              icon: Icons.add,
              onTap: onIncrementQty,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: hasMatchedSku
                ? () async {
                    await onBuyNow();
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              l10n.productDetailBuyNow,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canAddToCart
                ? () async {
                    await onAddToCart();
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color.fromRGBO(200, 200, 200, 1),
              foregroundColor: const Color.fromRGBO(58, 72, 91, 1),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              context.l10n.addToCart,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
