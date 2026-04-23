import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_detail_card_decoration.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_detail_info_panel_widget.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_detail_media_panel_widget.dart';
import 'package:george_pick_mate/features/product/services/product_sku_resolver.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';

class ProductDetailMainSection extends StatelessWidget {
  const ProductDetailMainSection({
    super.key,
    required this.detail,
    required this.selected,
    required this.selectedId,
    required this.skuRowSelection,
    required this.skuResolved,
    required this.variants,
    required this.images,
    required this.imageIndex,
    required this.productNum,
    required this.pageController,
    required this.thumbScrollController,
    required this.onPageChanged,
    required this.onThumbnailTap,
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
  final List<String> images;
  final int imageIndex;
  final int productNum;
  final PageController pageController;
  final ScrollController thumbScrollController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;
  final void Function(int pid) onSelectVariant;
  final void Function(int rowIndex, Options opt) onApplySpecOption;
  final VoidCallback onDecrementQty;
  final VoidCallback onIncrementQty;
  final Future<void> Function() onBuyNow;
  final Future<void> Function() onAddToCart;

  static const double _panelGap = 18;
  static const double _mediaAspectRatio = 1.3;

  @override
  Widget build(BuildContext context) {
    final isPhone = !context.isTabletUp;

    if (isPhone) {
      final infoHeight = (MediaQuery.sizeOf(context).height * 0.58).clamp(
        360.0,
        620.0,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: _mediaAspectRatio,
            child: ProductDetailMediaPanel(
              images: images,
              imageIndex: imageIndex,
              pageController: pageController,
              thumbScrollController: thumbScrollController,
              onPageChanged: onPageChanged,
              onThumbnailTap: onThumbnailTap,
            ),
          ),
          const SizedBox(height: _panelGap),
          SizedBox(
            height: infoHeight.toDouble(),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: productDetailCardDecoration(),
              child: ProductDetailInfoPanel(
                detail: detail,
                selected: selected,
                selectedId: selectedId,
                skuRowSelection: skuRowSelection,
                skuResolved: skuResolved,
                variants: variants,
                productNum: productNum,
                onSelectVariant: onSelectVariant,
                onApplySpecOption: onApplySpecOption,
                onDecrementQty: onDecrementQty,
                onIncrementQty: onIncrementQty,
                onBuyNow: onBuyNow,
                onAddToCart: onAddToCart,
              ),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.maxWidth;
        final leftWidth = (rowWidth - _panelGap) * 0.6;
        final rightWidth = (rowWidth - _panelGap) * 0.4;
        final panelHeight = leftWidth / _mediaAspectRatio;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: panelHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: leftWidth,
                  child: ProductDetailMediaPanel(
                    images: images,
                    imageIndex: imageIndex,
                    pageController: pageController,
                    thumbScrollController: thumbScrollController,
                    onPageChanged: onPageChanged,
                    onThumbnailTap: onThumbnailTap,
                  ),
                ),
                const SizedBox(width: _panelGap),
                SizedBox(
                  width: rightWidth,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: productDetailCardDecoration(),
                    child: ProductDetailInfoPanel(
                      detail: detail,
                      selected: selected,
                      selectedId: selectedId,
                      skuRowSelection: skuRowSelection,
                      skuResolved: skuResolved,
                      variants: variants,
                      productNum: productNum,
                      onSelectVariant: onSelectVariant,
                      onApplySpecOption: onApplySpecOption,
                      onDecrementQty: onDecrementQty,
                      onIncrementQty: onIncrementQty,
                      onBuyNow: onBuyNow,
                      onAddToCart: onAddToCart,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
