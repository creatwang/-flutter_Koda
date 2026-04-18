import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/cart/controllers/cart_providers.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/services/product_sku_resolver.dart';
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
  List<Options>? _skuSelectedOptions;
  int? _skuSelectionOwnerId;
  bool _skuBootstrapped = false;
  late final PageController _pageController;
  late final ScrollController _thumbScrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _thumbScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _selectedProductId = null;
      _skuSelectedOptions = null;
      _skuSelectionOwnerId = null;
      _skuBootstrapped = false;
      _productNum = 1;
    }
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

    ref.listen<AsyncValue<ProductDetailDto>>(
      productDetailProvider(widget.productId),
      (previous, next) {
        next.whenData((detail) {
          final variants = detail.product ?? const <Product>[];
          if (variants.isEmpty || !mounted || _skuBootstrapped) return;
          _skuBootstrapped = true;
          final fallbackId = detail.id ?? variants.first.id ?? widget.productId;
          setState(() {
            _selectedProductId ??= fallbackId;
            final sel =
                variants.firstWhereOrNull((e) => e.id == _selectedProductId) ??
                variants.first;
            _skuSelectedOptions = ProductSkuResolver.getDefaultSelection(sel);
            _skuSelectionOwnerId = sel.id;
          });
        });
      },
    );

    return AdaptiveScaffold(
      title: l10n.appTitle,
      automaticallyImplyLeading: false,
      bottomBarVisibility: AdaptiveBottomBarVisibility.never,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Assets.images.detailBgc.image(
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFFE8ECEF)),
          ),
          SafeArea(
            child: detailState.when(
              loading: () => const AppLoadingView(),
              error: (error, _) => AppErrorView(
                message: l10n.productDetailLoadFailed(error.toString()),
                onRetry: () =>
                    ref.invalidate(productDetailProvider(widget.productId)),
              ),
              data: (detail) => _buildDetailContent(context, detail),
            ),
          ),
        ],
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

    final images = _buildGalleryImages(detail, variants);
    final imageIndex = images.isEmpty
        ? 0
        : _selectedImageIndex.clamp(0, images.length - 1);
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
                      skuRowSelection: skuRowSelection,
                      skuResolved: skuResolved,
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
              backgroundColor: WidgetStateProperty.all(
                Color.fromRGBO(129, 119, 110, 1),
              ),
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
    required List<Options> skuRowSelection,
    required ProductSkuResolveResult skuResolved,
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
                skuRowSelection,
                skuResolved,
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
                  child: _buildMediaPanel(
                    images: images,
                    imageIndex: imageIndex,
                  ),
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
                      skuRowSelection,
                      skuResolved,
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
    List<Options> skuRowSelection,
    ProductSkuResolveResult skuResolved,
    List<Product> variants,
  ) {
    final l10n = context.l10n;
    final title = selected.name ?? detail.name ?? '--';
    // final category = (selected.categoryName ?? detail.categoryName ?? '').toUpperCase();
    final productCode = (selected.uniqid ?? detail.uniqid ?? '');
    final hasMatchedSku = skuResolved.sub != null;
    final unitPrice = _resolveUnitPrice(skuResolved.sub);
    final totalPrice = unitPrice * _productNum;
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
                '\$${totalPrice.toStringAsFixed(2)}',
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
                                    : () =>
                                          _selectVariantProduct(pid, variants),
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
                                final display =
                                    option.name ?? option.nameCn ?? '--';
                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _applySpecOption(
                                    rowIndex,
                                    option,
                                    selected,
                                    variants,
                                  ),
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
            onPressed: hasMatchedSku
                ? () {
                    _addProductToCart(
                      selected,
                      variants,
                      _productNum,
                      skuResolved.sub,
                    );
                    context.go(AppRoutes.homeWithTab('cart'));
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
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: hasMatchedSku
                ? () {
                    _addProductToCart(
                      selected,
                      variants,
                      _productNum,
                      skuResolved.sub,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.productAddedToCart(title)),
                      ),
                    );
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Color.fromRGBO(200, 200, 200, 1),
              foregroundColor: Color.fromRGBO(58, 72, 91, 1),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(context.l10n.addToCart, style: TextStyle(fontSize: 14)),
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
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white70,
                          ),
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
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
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

  ProductItem _toProductItem(Product product, {ProductSub? resolvedSub}) {
    final price = resolvedSub != null
        ? (resolvedSub.salesPrice ?? 0)
        : (product.price ?? 0);
    final id = resolvedSub?.pid ?? product.id ?? widget.productId;
    return ProductItem(
      id: id,
      categoryName: product.categoryName ?? '',
      categoryId: product.categoryId ?? 0,
      name: product.name ?? '',
      unit: product.unit ?? '',
      maxPrice: product.maxPrice ?? 0,
      price: price,
      isHot: '${product.isHot ?? 0}',
      mainImage: product.mainImage ?? '',
      isCollect: product.isCollect ?? false,
    );
  }

  void _selectVariantProduct(int pid, List<Product> variants) {
    if (_selectedProductId == pid) return;
    final product = variants.firstWhereOrNull((e) => e.id == pid);
    if (product == null) return;
    setState(() {
      _selectedProductId = pid;
      _skuSelectedOptions = ProductSkuResolver.getDefaultSelection(product);
      _skuSelectionOwnerId = product.id;
    });
  }

  void _applySpecOption(
    int rowIndex,
    Options opt,
    Product selected,
    List<Product> variants,
  ) {
    final rows = selected.specValue ?? const <SpecValue>[];
    if (rowIndex < 0 || rowIndex >= rows.length) return;
    final row = rows[rowIndex];
    final hit = (row.options ?? const <Options>[]).firstWhereOrNull(
      (o) => o.spec == opt.spec,
    );
    if (hit == null) return;

    final base =
        (_skuSelectedOptions != null &&
            _skuSelectedOptions!.length == rows.length &&
            _skuSelectionOwnerId == selected.id)
        ? List<Options>.from(_skuSelectedOptions!)
        : List<Options>.from(ProductSkuResolver.getDefaultSelection(selected));
    base[rowIndex] = hit;

    final activePid = _selectedProductId ?? selected.id ?? 0;
    final resolved = ProductSkuResolver.resolveSubForSelection(
      selected,
      base,
      variants,
      activePid,
    );

    setState(() {
      final sub = resolved.sub;
      if (sub != null && sub.pid != null && sub.pid != activePid) {
        final newPid = sub.pid!;
        _selectedProductId = newPid;
        final newProduct =
            variants.firstWhereOrNull((p) => p.id == newPid) ?? selected;
        _skuSelectedOptions = ProductSkuResolver.selectionFromSub(
          newProduct,
          sub,
        );
        _skuSelectionOwnerId = newProduct.id;
      } else if (sub != null && resolved.via == 'pidFallback') {
        final owner =
            variants.firstWhereOrNull((p) => p.id == sub.pid) ?? selected;
        _skuSelectedOptions = ProductSkuResolver.selectionFromSub(owner, sub);
        _skuSelectionOwnerId = owner.id;
        _selectedProductId = sub.pid;
      } else {
        _skuSelectedOptions = base;
        _skuSelectionOwnerId = selected.id;
      }
    });
  }

  /// 单价仅取自当前解析命中的 [ProductSub.salesPrice]（与接口 `sales_price` 一致）。
  double _resolveUnitPrice(ProductSub? resolvedSub) {
    if (resolvedSub != null) {
      return resolvedSub.salesPrice ?? 0;
    }
    return 0;
  }

  void _addProductToCart(
    Product selected,
    List<Product> variants,
    int qty,
    ProductSub? resolvedSub,
  ) {
    final productForCart = resolvedSub?.pid != null
        ? (variants.firstWhereOrNull((p) => p.id == resolvedSub!.pid) ??
              selected)
        : selected;
    final cart = ref.read(cartControllerProvider.notifier);
    for (var i = 0; i < qty; i++) {
      cart.addProduct(_toProductItem(productForCart, resolvedSub: resolvedSub));
    }
  }

  List<String> _buildGalleryImages(
    ProductDetailDto detail,
    List<Product> variants,
  ) {
    final detailImages = (detail.subImages ?? const <String>[])
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (detailImages.isNotEmpty) return detailImages;

    final firstVariantImages =
        (variants.firstOrNull?.subImages ?? const <String>[])
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
      final currentPage =
          (_pageController.page ?? _pageController.initialPage.toDouble())
              .round();
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
  const _QtyAdjustButton({required this.icon, this.onTap});

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
