import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
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
    final specSummary = widget.skuRowSelection
        .map((opt) => (opt.nameCn ?? opt.name ?? '').trim())
        .where((name) => name.isNotEmpty)
        .join(' / ');
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
                'SKU',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (specSummary.isNotEmpty)
                Text(specSummary, style: theme.textTheme.bodyMedium),
              if (specCode.isNotEmpty) ...[
                if (specSummary.isNotEmpty) const SizedBox(height: 4),
                Text(
                  'Index: $specCode',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (referenceCode.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Ref. $referenceCode',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
