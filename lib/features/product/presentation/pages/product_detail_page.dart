import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_technical_data_panel.dart';
import 'package:groe_app_pad/gen/assets.gen.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/adaptive_scaffold.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({required this.productId, super.key});

  final int productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int? _selectedProductId;
  int _selectedImageIndex = 0;
  int _productNum = 1;
  late final PageController _pageController;
  late final ScrollController _thumbScrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _thumbScrollController = ScrollController();
  }

  @override
  void dispose() {
    _thumbScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detailState = ref.watch(productDetailProvider(widget.productId));
    return AdaptiveScaffold(
      title: l10n.appTitle,
      automaticallyImplyLeading: false,
      bottomBarVisibility: AdaptiveBottomBarVisibility.never,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Assets.images.detailBgc.image(
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE8ECEF),
              ),
            ),
            detailState.when(
              loading: () => const AppLoadingView(),
              error: (error, _) => AppErrorView(
                message: l10n.productDetailLoadFailed(error.toString()),
                onRetry: () =>
                    ref.invalidate(productDetailProvider(widget.productId)),
              ),
              data: (detail) => _buildDetailContent(context, detail),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, ProductDetailDto detail) {
    final l10n = context.l10n;
    final variants = detail.product ?? const <Product>[];
    if (variants.isEmpty) {
      return AppErrorView(message: l10n.productDetailVariantsEmpty);
    }

    final fallbackId = detail.id ?? variants.first.id ?? widget.productId;
    final currentId = _selectedProductId ?? fallbackId;
    final selected =
        variants.firstWhereOrNull((e) => e.id == currentId) ?? variants.first;
    final selectedId = selected.id ?? fallbackId;

    final optionPathByPid = <int, String>{
      for (final item in detail.productSub ?? const <ProductSub>[])
        if (item.pid != null && item.sIndex != null) item.pid!: item.sIndex!,
    };
    if (optionPathByPid.isEmpty) {
      for (final item in variants) {
        final p = item.productSub?.firstOrNull;
        if (p?.pid != null && p?.sIndex != null) {
          optionPathByPid[p!.pid!] = p.sIndex!;
        }
      }
    }
    final optionPath = optionPathByPid[selectedId] ?? '';

    final images = _buildGalleryImages(detail, variants);
    final imageIndex =
        images.isEmpty ? 0 : _selectedImageIndex.clamp(0, images.length - 1);
    _syncCarouselIndex(imageIndex, hasImages: images.isNotEmpty);
    final selectedParams = selected.productParam ?? const <ProductParam>[];
    final contentPadding = context.isTabletUp
        ? const EdgeInsets.fromLTRB(62, 20, 62, 10)
        : const EdgeInsets.fromLTRB(20, 16, 20, 10);

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: contentPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 56),
                    _buildMainSection(
                      context: context,
                      detail: detail,
                      selected: selected,
                      selectedId: selectedId,
                      optionPath: optionPath,
                      variants: variants,
                      images: images,
                      imageIndex: imageIndex,
                    ),
                    const SizedBox(height: 16),
                    ProductTechnicalDataPanel(
                      referenceCode: detail.uniqid ?? '--',
                      params: selectedParams,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: contentPadding.left,
          top: 12,
          child: FilledButton.icon(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.white),
              backgroundColor: WidgetStateProperty.all(Color.fromRGBO(129, 119, 110, 1)),
            ),
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(
              l10n.productDetailBackToList,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainSection({
    required BuildContext context,
    required ProductDetailDto detail,
    required Product selected,
    required int selectedId,
    required String optionPath,
    required List<Product> variants,
    required List<String> images,
    required int imageIndex,
  }) {
    const panelGap = 18.0;
    const mediaAspectRatio = 1.3;
    final isPhone = !context.isTabletUp;

    if (isPhone) {
      final infoHeight = (MediaQuery.of(context).size.height * 0.58).clamp(
        360.0,
        620.0,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: mediaAspectRatio,
            child: _buildMediaPanel(images: images, imageIndex: imageIndex),
          ),
          const SizedBox(height: panelGap),
          SizedBox(
            height: infoHeight,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: _cardDecoration(),
              child: _buildInfoPanel(
                context,
                detail,
                selected,
                selectedId,
                optionPath,
                variants,
              ),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.maxWidth;
        final leftWidth = (rowWidth - panelGap) * 0.6;
        final rightWidth = (rowWidth - panelGap) * 0.4;
        final panelHeight = leftWidth / mediaAspectRatio;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: panelHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: leftWidth,
                  child: _buildMediaPanel(images: images, imageIndex: imageIndex),
                ),
                const SizedBox(width: panelGap),
                SizedBox(
                  width: rightWidth,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: _buildInfoPanel(
                      context,
                      detail,
                      selected,
                      selectedId,
                      optionPath,
                      variants,
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

  Widget _buildInfoPanel(
    BuildContext context,
    ProductDetailDto detail,
    Product selected,
    int selectedId,
    String optionPath,
    List<Product> variants,
  )
  {
    final l10n = context.l10n;
    final title = selected.name ?? detail.name ?? '--';
    // final category = (selected.categoryName ?? detail.categoryName ?? '').toUpperCase();
    final productCode = (selected.uniqid ?? detail.uniqid ?? '');
    final unitPrice = _resolveUnitPrice(detail, selected, selectedId);
    final unitMaxPrice = selected.maxPrice ?? detail.maxPrice ?? unitPrice;
    final totalPrice = unitPrice * _productNum;
    final totalMaxPrice = unitMaxPrice * _productNum;
    final specGroups = selected.specValue ?? const <SpecValue>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(productCode,
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
            Text(
              '\$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            /*if (totalMaxPrice > totalPrice)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '€${totalMaxPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    decoration: TextDecoration.lineThrough,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),*/
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
                        children: variants.map((product) {
                          final pid = product.id;
                          final isSelected = pid != null && pid == selectedId;
                          final display = product.name ?? product.nameCn ?? '--';
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: pid == null
                                ? null
                                : () {
                                    _selectProduct(pid);
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.25),
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
                        }).toList(growable: false),
                      ),
                    ],
                  ),
                ),
                ...specGroups
                    .where((group) => (group.options ?? const <Options>[]).isNotEmpty)
                    .map((group) {
                  final options = group.options ?? const <Options>[];
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
                          children: options.map((option) {
                            final spec = option.spec ?? '';
                            final isSelected = spec.isNotEmpty && optionPath.contains(spec);
                            final display = option.name ?? option.nameCn ?? '--';
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                final pid = option.pid?.firstOrNull;
                                if (pid == null) return;
                                _selectProduct(pid);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.25),
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
                          }).toList(growable: false),
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
            _QtyAdjustButton(
              icon: Icons.remove,
              onTap: _productNum <= 1
                  ? null
                  : () => setState(() {
                _productNum -= 1;
              }),
            ),
            Container(
              width: 46,
              alignment: Alignment.center,
              child: Text(
                '$_productNum',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _QtyAdjustButton(
              icon: Icons.add,
              onTap: () => setState(() {
                _productNum += 1;
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              _addProductToCart(selected, _productNum);
              context.go(AppRoutes.homeWithTab('cart'));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(l10n.productDetailBuyNow, style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              _addProductToCart(selected, _productNum);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.productAddedToCart(title))),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Color.fromRGBO(200, 200, 200, 1),
              foregroundColor: Color.fromRGBO(58, 72, 91, 1),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(context.l10n.addToCart, style: TextStyle(fontSize: 14),),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPanel({
    required List<String> images,
    required int imageIndex,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 110,
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView.separated(
              controller: _thumbScrollController,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final selectedThumb = imageIndex == index;
                return GestureDetector(
                  onTap: () => _onThumbnailTap(index),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 2.0,
                        color: selectedThumb
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0x22111111),
                          child: Icon(Icons.broken_image, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.12),
                child: images.isEmpty
                    ? const Center(child: Icon(Icons.image_not_supported))
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          if (_selectedImageIndex == index) return;
                          setState(() => _selectedImageIndex = index);
                        },
                        itemBuilder: (_, index) => Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.image_not_supported)),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    );
  }

  ProductItem _toProductItem(Product product) {
    return ProductItem(
      id: product.id ?? widget.productId,
      categoryName: product.categoryName ?? '',
      categoryId: product.categoryId ?? 0,
      name: product.name ?? '',
      unit: product.unit ?? '',
      maxPrice: product.maxPrice ?? 0,
      price: product.price ?? 0,
      isHot: '${product.isHot ?? 0}',
      mainImage: product.mainImage ?? '',
      isCollect: product.isCollect ?? false,
    );
  }

  void _selectProduct(int pid) {
    if (_selectedProductId == pid) return;
    setState(() {
      _selectedProductId = pid;
    });
  }

  double _resolveUnitPrice(ProductDetailDto detail, Product selected, int selectedId) {
    final detailSub = detail.productSub?.firstWhereOrNull((e) => e.pid == selectedId);
    final selectedSub = selected.productSub?.firstWhereOrNull((e) => e.pid == selectedId);
    final salesPrice = detailSub?.salesPrice ?? selectedSub?.salesPrice;
    return salesPrice ?? selected.price ?? detail.price ?? 0;
  }

  void _addProductToCart(Product selected, int qty) {
    final cart = ref.read(cartControllerProvider.notifier);
    for (var i = 0; i < qty; i++) {
      cart.addProduct(_toProductItem(selected));
    }
  }

  List<String> _buildGalleryImages(ProductDetailDto detail, List<Product> variants) {
    final detailImages = (detail.subImages ?? const <String>[])
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (detailImages.isNotEmpty) return detailImages;

    final firstVariantImages = (variants.firstOrNull?.subImages ?? const <String>[])
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (firstVariantImages.isNotEmpty) return firstVariantImages;

    final detailMainImage = detail.mainImage?.trim();
    if (detailMainImage != null && detailMainImage.isNotEmpty) {
      return <String>[detailMainImage];
    }

    final firstVariantMain = variants.firstOrNull?.mainImage?.trim();
    if (firstVariantMain != null && firstVariantMain.isNotEmpty) {
      return <String>[firstVariantMain];
    }

    return const <String>[];
  }

  void _syncCarouselIndex(int imageIndex, {required bool hasImages}) {
    if (!hasImages) return;

    if (_selectedImageIndex != imageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedImageIndex = imageIndex);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSelectedThumbnailVisible(imageIndex);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final currentPage = (_pageController.page ?? _pageController.initialPage.toDouble()).round();
      if (currentPage != imageIndex) {
        _pageController.jumpToPage(imageIndex);
      }
    });
  }

  void _onThumbnailTap(int index) {
    if (_selectedImageIndex != index) {
      setState(() => _selectedImageIndex = index);
    }
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _ensureSelectedThumbnailVisible(int index) {
    if (!mounted || !_thumbScrollController.hasClients) return;

    const itemHeight = 74.0;
    const itemGap = 10.0;
    const itemExtent = itemHeight + itemGap;

    final position = _thumbScrollController.position;
    final currentOffset = position.pixels;
    final viewportHeight = position.viewportDimension;

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

    if (targetOffset == null) return;

    final safeOffset = targetOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _thumbScrollController.animateTo(
      safeOffset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}

class _QtyAdjustButton extends StatelessWidget {
  const _QtyAdjustButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.white38 : Colors.white,
        ),
      ),
    );
  }
}
