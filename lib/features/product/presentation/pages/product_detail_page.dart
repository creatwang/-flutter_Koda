import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/features/product/controllers/product_detail_controller.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_detail_main_section_widget.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_technical_data_panel.dart';
import 'package:george_pick_mate/features/product/services/product_sku_cart_helpers.dart';
import 'package:george_pick_mate/gen/assets.gen.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_back_button.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/adaptive_scaffold.dart';
import 'package:george_pick_mate/shared/widgets/app_error_view.dart';
import 'package:george_pick_mate/shared/widgets/app_loading_view.dart';

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
  bool _isAddToCartSubmitting = false;
  bool _isBuyNowSubmitting = false;
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
      _isAddToCartSubmitting = false;
      _isBuyNowSubmitting = false;
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
          final pick = ProductDetailController.bootstrapSkuPickFromDetail(
            detail: detail,
            pageProductId: widget.productId,
            selectedProductId: _selectedProductId,
          );
          setState(() {
            _selectedProductId = pick.selectedProductId;
            _skuSelectedOptions = pick.skuSelectedOptions;
            _skuSelectionOwnerId = pick.skuSelectionOwnerId;
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
    final resolved = ProductDetailResolvedSelection.tryResolve(
      detail: detail,
      pageProductId: widget.productId,
      selectedProductId: _selectedProductId,
      skuSelectedOptions: _skuSelectedOptions,
      skuSelectionOwnerId: _skuSelectionOwnerId,
    );
    if (resolved == null) {
      return AppErrorView(message: l10n.productDetailVariantsEmpty);
    }

    final variants = detail.product ?? const <Product>[];
    final images = resolved.galleryImages;
    final imageIndex = images.isEmpty
        ? 0
        : _selectedImageIndex.clamp(0, images.length - 1);
    _syncCarouselIndex(imageIndex, hasImages: images.isNotEmpty);
    final selectedParams =
        resolved.selected.productParam ?? const <ProductParam>[];
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
                    ProductDetailMainSection(
                      detail: detail,
                      selected: resolved.selected,
                      selectedId: resolved.selectedId,
                      skuRowSelection: resolved.skuRowSelection,
                      skuResolved: resolved.skuResolved,
                      variants: variants,
                      images: images,
                      imageIndex: imageIndex,
                      productNum: _productNum,
                      pageController: _pageController,
                      thumbScrollController: _thumbScrollController,
                      onPageChanged: (index) {
                        if (_selectedImageIndex == index) return;
                        setState(() => _selectedImageIndex = index);
                        _ensureSelectedThumbnailVisible(index);
                      },
                      onThumbnailTap: _onThumbnailTap,
                      onSelectVariant: (pid) =>
                          _selectVariantProduct(pid, variants),
                      onApplySpecOption: (rowIndex, opt) => _applySpecOption(
                        rowIndex,
                        opt,
                        resolved.selected,
                        variants,
                      ),
                      onDecrementQty: () => setState(() {
                        _productNum -= 1;
                      }),
                      onIncrementQty: () => setState(() {
                        _productNum += 1;
                      }),
                      onBuyNow: () => _onBuyNow(resolved),
                      onAddToCart: () =>
                          _onAddToCart(context, detail, resolved),
                      isBuyNowSubmitting: _isBuyNowSubmitting,
                      isAddToCartSubmitting: _isAddToCartSubmitting,
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
          child: GeorgeBackButton(
            label: 'Back to Product List',
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }

  Future<void> _onBuyNow(ProductDetailResolvedSelection resolved) async {
    if (_isBuyNowSubmitting) return;
    setState(() => _isBuyNowSubmitting = true);
    try {
      final ok = await _submitCartCreate(
        qty: _productNum,
        resolvedSub: resolved.skuResolved.sub,
        skuRowSelection: resolved.skuRowSelection,
      );
      if (!mounted) return;
      if (ok) {
        context.go(AppRoutes.homeWithTab('cart'));
      }
    } finally {
      if (mounted) {
        setState(() => _isBuyNowSubmitting = false);
      }
    }
  }

  Future<void> _onAddToCart(
    BuildContext context,
    ProductDetailDto detail,
    ProductDetailResolvedSelection resolved,
  ) async {
    if (_isAddToCartSubmitting) return;
    final title = resolved.selected.name ?? detail.name ?? '--';
    setState(() => _isAddToCartSubmitting = true);
    try {
      final ok = await _submitCartCreate(
        qty: _productNum,
        resolvedSub: resolved.skuResolved.sub,
        skuRowSelection: resolved.skuRowSelection,
      );
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.productAddedToCart(title))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddToCartSubmitting = false);
      }
    }
  }

  void _selectVariantProduct(int pid, List<Product> variants) {
    final pick = ProductDetailController.pickVariantOrNull(
      pid: pid,
      currentSelectedProductId: _selectedProductId,
      variants: variants,
    );
    if (pick == null) return;
    setState(() {
      _selectedProductId = pick.selectedProductId;
      _skuSelectedOptions = pick.skuSelectedOptions;
      _skuSelectionOwnerId = pick.skuSelectionOwnerId;
    });
  }

  void _applySpecOption(
    int rowIndex,
    Options opt,
    Product selected,
    List<Product> variants,
  ) {
    final pick = ProductDetailController.applySpecOptionPickOrNull(
      rowIndex: rowIndex,
      opt: opt,
      selected: selected,
      variants: variants,
      skuSelectedOptions: _skuSelectedOptions,
      skuSelectionOwnerId: _skuSelectionOwnerId,
      selectedProductId: _selectedProductId,
    );
    if (pick == null) return;
    setState(() {
      _selectedProductId = pick.selectedProductId;
      _skuSelectedOptions = pick.skuSelectedOptions;
      _skuSelectionOwnerId = pick.skuSelectionOwnerId;
    });
  }

  Future<bool> _submitCartCreate({
    required int qty,
    required ProductSub? resolvedSub,
    required List<Options> skuRowSelection,
  }) async {
    final sub = resolvedSub;
    if (sub == null || sub.pid == null) return false;
    final subIndex = ProductSkuCartHelpers.subIndexForApi(sub);
    if (subIndex.isEmpty) return false;
    final subName = ProductSkuCartHelpers.buildCartSubName(
      sub: sub,
      skuRowSelection: skuRowSelection,
    );
    final space = await resolveSpaceForCartAdd(context);
    if (space == null) return false;
    return ref
        .read(cartControllerProvider.notifier)
        .createCartItem(
          productId: sub.pid!,
          subIndex: subIndex,
          productNum: qty,
          space: space,
          subName: subName,
        );
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
    final position = _thumbScrollController.position;
    final target = ProductDetailController.targetThumbScrollOffsetOrNull(
      index: index,
      currentOffset: position.pixels,
      viewportHeight: position.viewportDimension,
      minScrollExtent: position.minScrollExtent,
      maxScrollExtent: position.maxScrollExtent,
    );
    if (target == null) return;
    _thumbScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}
