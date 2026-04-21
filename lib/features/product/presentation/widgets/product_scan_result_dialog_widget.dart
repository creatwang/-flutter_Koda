import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/services/product_sku_resolver.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

typedef ProductScanResultAddToCartCallback =
    Future<bool> Function(BuildContext dialogContext);

/// 扫码结果弹窗背景（设计稿 #282828）。
const Color _kProductScanDialogBg = Color(0xFF282828);

const Color _kScanLabelColor = Color(0xFFA6A6A6);
const Color _kScanAddButtonBg = Color(0xFF000000);
const Color _kScanCancelButtonBg = Color(0xFFE8E8E8);

const double _kScanDialogRadius = 12;
const double _kScanOuterPadding = 22;
const double _kScanLabelColumnWidth = 118;
const double _kScanImageHeight = 215;
const double _kScanFooterGap = 12;
const double _kScanButtonHeight = 48;
const double _kScanButtonRadius = 8;

List<({String label, String value})> _buildSkuDetailLabelValueRows({
  required Product selected,
  required ProductSub selectedSub,
  required List<Options> skuRowSelection,
}) {
  final specRows = selected.specValue ?? const <SpecValue>[];
  final specLookup = ProductSkuResolver.buildSpecOptionsLookup(selected);
  final indexTokens = ProductSkuResolver.splitSpecIndexTokens(
    ProductSkuResolver.compositeSpecIndex(selectedSub),
  );
  final rows = <({String label, String value})>[];
  final productName = (selectedSub.name  ?? selectedSub.nameCn ?? '').trim();

  for (var i = 0; i < specRows.length; i++) {
    final group = specRows[i];
    final options = group.options ?? const <Options>[];
    if (options.isEmpty) continue;
    final labelEn = (group.name ?? '').trim();
    final label = labelEn.isNotEmpty
        ? labelEn
        : (group.nameCn ?? '').trim();
    final fallbackAttr = (group.attrIndex ?? '').trim().toUpperCase();
    final effectiveLabel = label.isNotEmpty ? label : fallbackAttr;
    if (effectiveLabel.isEmpty) continue;
    final token = i < indexTokens.length ? indexTokens[i] : null;
    final fromMap = token != null ? specLookup[token] : null;
    final fromSelection =
        i < skuRowSelection.length ? skuRowSelection[i] : null;
    final resolved = fromMap ?? fromSelection;
    final valueText =
        (resolved?.name ?? resolved?.nameCn ?? '--').trim();
    rows.add((
      label: effectiveLabel,
      value: valueText.isNotEmpty ? valueText : '--',
    ));
  }
  return rows;
}

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
    final selected = widget.selected;
    final detail = widget.detail;
    final selectedSub = widget.selectedSub;
    final title =
        selected.name ??
        selected.nameCn ??
        detail.name ??
        detail.nameCn ??
        '--';
    final imageUrl = (selected.mainImage ?? detail.mainImage ?? '').trim();
    final unitPrice = selectedSub.salesPrice ?? 0;
    final unit = (selected.unit ?? detail.unit ?? '').trim();
    final model = (selectedSub.model ?? '').trim();
    final skuRows = _buildSkuDetailLabelValueRows(
      selected: selected,
      selectedSub: selectedSub,
      skuRowSelection: widget.skuRowSelection,
    );
    final params = (selected.productParam ?? const <ProductParam>[])
        .where(
          (item) =>
              (item.name ?? '').trim().isNotEmpty &&
              (item.value ?? '').trim().isNotEmpty,
        )
        .toList(growable: false);

    final detailRows = <({String label, String value})>[...skuRows];
    if (unitPrice > 0) {
      detailRows.add((
        label: 'Price',
        value: '\$${unitPrice.toStringAsFixed(2)}',
      ));
    }
    if (unit.isNotEmpty) {
      detailRows.add((label: 'Unit', value: unit));
    }
    if (model.isNotEmpty) {
      detailRows.add((label: 'Model', value: model));
    }

    final mq = MediaQuery.sizeOf(context);
    final panelW = (mq.width - 48).clamp(300.0, 430.0);
    final bodyH = (mq.height * 0.76).clamp(380.0, 720.0);
    final innerW = panelW - _kScanOuterPadding * 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: SizedBox(
        width: panelW,
        height: bodyH,
        child: Material(
          color: _kProductScanDialogBg,
          elevation: 18,
          shadowColor: Colors.black54,
          borderRadius: BorderRadius.circular(_kScanDialogRadius),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        _kScanOuterPadding,
                        44,
                        _kScanOuterPadding,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ColoredBox(
                              color: Colors.white.withValues(alpha: 0.08),
                              child: SizedBox(
                                height: _kScanImageHeight,
                                width: innerW,
                                child: imageUrl.isEmpty
                                    ? const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.white38,
                                          size: 48,
                                        ),
                                      )
                                    : Image.network(
                                        imageUrl,
                                        width: innerW,
                                        height: _kScanImageHeight,
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.white38,
                                          size: 48,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              height: 1.2,
                            ),
                          ),
                          ...detailRows.asMap().entries.map((e) {
                            return _ProductScanDetailRow(
                              label: e.value.label,
                              value: e.value.value,
                              paddingTop: e.key == 0 ? 18 : 14,
                            );
                          }),
                          if (params.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            ...params.asMap().entries.map((e) {
                              final item = e.value;
                              return _ProductScanDetailRow(
                                label: (item.name ?? '').trim(),
                                value: (item.value ?? '').trim(),
                                paddingTop: e.key == 0 ? 14 : 12,
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _ProductScanCloseControl(
                        enabled: !_isSubmitting,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _kScanOuterPadding,
                  4,
                  _kScanOuterPadding,
                  _kScanOuterPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: _kScanButtonHeight,
                        child: FilledButton(
                          onPressed:
                              _isSubmitting ? null : _onAddToCartPressed,
                          style: FilledButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _kScanAddButtonBg,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                _kScanAddButtonBg.withValues(alpha: 0.45),
                            disabledForegroundColor: Colors.white54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                _kScanButtonRadius,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(context.l10n.cartConfirmAdd),
                        ),
                      ),
                    ),
                    const SizedBox(width: _kScanFooterGap),
                    Expanded(
                      child: SizedBox(
                        height: _kScanButtonHeight,
                        child: FilledButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: FilledButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _kScanCancelButtonBg,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor:
                                _kScanCancelButtonBg.withValues(alpha: 0.5),
                            disabledForegroundColor: Colors.black38,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                _kScanButtonRadius,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          child: Text(context.l10n.commonCancel),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductScanDetailRow extends StatelessWidget {
  const _ProductScanDetailRow({
    required this.label,
    required this.value,
    required this.paddingTop,
  });

  final String label;
  final String value;
  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _kScanLabelColumnWidth,
            child: Text(
              label,
              style: const TextStyle(
                color: _kScanLabelColor,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductScanCloseControl extends StatelessWidget {
  const _ProductScanCloseControl({
    required this.onTap,
    required this.enabled,
  });

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            ),
          ),
          child: Icon(
            Icons.close,
            color: Colors.white.withValues(alpha: enabled ? 1 : 0.4),
            size: 20,
          ),
        ),
      ),
    );
  }
}
