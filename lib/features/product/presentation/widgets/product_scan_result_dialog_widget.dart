import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/services/product_sku_resolver.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

typedef ProductScanResultAddToCartCallback =
    Future<bool> Function(BuildContext dialogContext);

Future<bool> showProductScanResultDialog({
  required BuildContext context,
  required ProductDetailDto detail,
  required Product selected,
  required ProductSub selectedSub,
  required List<Options> skuRowSelection,
  required ProductScanResultAddToCartCallback onAddToCart,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => ProductScanResultDialogWidget(
      detail: detail,
      selected: selected,
      selectedSub: selectedSub,
      skuRowSelection: skuRowSelection,
      onAddToCart: onAddToCart,
    ),
  );
  return result == true;
}

class ProductScanResultDialogWidget extends StatefulWidget {
  const ProductScanResultDialogWidget({
    required this.detail,
    required this.selected,
    required this.selectedSub,
    required this.skuRowSelection,
    required this.onAddToCart,
    super.key,
  });

  final ProductDetailDto detail;
  final Product selected;
  final ProductSub selectedSub;
  final List<Options> skuRowSelection;
  final ProductScanResultAddToCartCallback onAddToCart;

  @override
  State<ProductScanResultDialogWidget> createState() =>
      _ProductScanResultDialogWidgetState();
}

class _ProductScanResultDialogWidgetState
    extends State<ProductScanResultDialogWidget> {
  bool _isSubmitting = false;

  Future<void> _onAddToCartPressed() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final ok = await widget.onAddToCart(context);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = widget.selected;
    final detail = widget.detail;
    final selectedSub = widget.selectedSub;
    final title =
        selected.nameCn ?? selected.name ?? detail.nameCn ?? detail.name ?? '--';
    final imageUrl = (selected.mainImage ?? detail.mainImage ?? '').trim();
    final unitPrice = selectedSub.salesPrice ?? 0;
    final unit = (selected.unit ?? detail.unit ?? '').trim();
    final specRows = selected.specValue ?? const <SpecValue>[];
    final specLookup = ProductSkuResolver.buildSpecOptionsLookup(selected);
    final indexTokens = ProductSkuResolver.splitSpecIndexTokens(
      ProductSkuResolver.compositeSpecIndex(selectedSub),
    );
    final subDisplayName =(selectedSub.name ?? '').trim();
    final specCode = (selectedSub.index ?? selectedSub.sIndex ?? '').trim();
    final referenceCode = (detail.uniqid ?? '').trim();
    final params = (selected.productParam ?? const <ProductParam>[])
        .where(
          (item) =>
              (item.name ?? '').trim().isNotEmpty &&
              (item.value ?? '').trim().isNotEmpty,
        )
        .toList(growable: false);

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(context.l10n.productScanResult(title)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: colorScheme.surfaceContainerHigh,
                      child: SizedBox(
                        width: 84,
                        height: 84,
                        child: imageUrl.isEmpty
                            ? Icon(
                                Icons.image_not_supported_outlined,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${unitPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (unit.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(unit, style: theme.textTheme.bodySmall),
                        ],
                        if ((selectedSub.model ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Model: ${selectedSub.model}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                subDisplayName.isNotEmpty ? subDisplayName : '--',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 16
                ),
              ),
              ...specRows.asMap().entries.expand((entry) {
                final i = entry.key;
                final group = entry.value;
                final options = group.options ?? const <Options>[];
                if (options.isEmpty) return const <Widget>[];
                final labelEn = (group.name ?? '').trim();
                final label = labelEn.isNotEmpty
                    ? labelEn
                    : (group.nameCn ?? '').trim();
                final fallbackAttr =
                    (group.attrIndex ?? '').trim().toUpperCase();
                final effectiveLabel =
                    label.isNotEmpty ? label : fallbackAttr;
                if (effectiveLabel.isEmpty) return const <Widget>[];
                final token = i < indexTokens.length ? indexTokens[i] : null;
                final fromMap =
                    token != null ? specLookup[token] : null;
                final fromSelection = i < widget.skuRowSelection.length
                    ? widget.skuRowSelection[i]
                    : null;
                final resolved = fromMap ?? fromSelection;
                final valueText =
                    (resolved?.nameCn ?? resolved?.name ?? '--').trim();
                return <Widget>[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        effectiveLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white60,
                          fontSize: 14
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        valueText.isNotEmpty ? valueText : '--',
                        style: TextStyle(
                          color: Colors.white,
                            fontSize: 14
                        ),
                      ),
                    ],
                  )
                ];
              }),
              if (params.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Technical Data',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...params.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            (item.name ?? '').trim(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            (item.value ?? '').trim(),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _onAddToCartPressed,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.cartConfirmAdd),
        ),
      ],
    );
  }
}
