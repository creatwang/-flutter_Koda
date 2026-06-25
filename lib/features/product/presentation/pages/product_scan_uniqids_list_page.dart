import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/features/cart/services/cart_create_flow_services.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/features/product/controllers/product_scan_uniqids_providers.dart';
import 'package:george_pick_mate/features/product/models/paginated_products_state.dart';
import 'package:george_pick_mate/features/product/models/product_item.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_grid_section.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_sku_cart_side_sheet_widget.dart';
import 'package:george_pick_mate/features/product/services/product_services.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';

class ProductScanUniqidsListPage extends ConsumerStatefulWidget {
  const ProductScanUniqidsListPage({required this.uniqids, super.key});

  final List<String> uniqids;

  @override
  ConsumerState<ProductScanUniqidsListPage> createState() =>
      _ProductScanUniqidsListPageState();
}

class _ProductScanUniqidsListPageState
    extends ConsumerState<ProductScanUniqidsListPage> {
  final ScrollController _scrollController = ScrollController();
  late final ProviderSubscription<AsyncValue<PaginatedProductsState>>
  _productsSubscription;
  bool _ensureLoadScheduled = false;
  final Map<int, bool> _collectOverrides = <int, bool>{};
  final Set<int> _collectSubmitting = <int>{};
  final Set<int> _addToCartSubmitting = <int>{};
  int _addToCartFlowEpoch = 0;

  String get _providerKey => encodeScanUniqidsProviderKey(widget.uniqids);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _productsSubscription = ref.listenManual<
      AsyncValue<PaginatedProductsState>
    >(scanUniqidsProductsProvider(_providerKey), (_, next) {
      if (next is AsyncData<PaginatedProductsState>) {
        _ensureScrollableAndLoadMoreIfNeeded();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 300) {
      ref.read(scanUniqidsProductsProvider(_providerKey).notifier).loadMoreOnScroll();
    }
  }

  void _ensureScrollableAndLoadMoreIfNeeded() {
    if (_ensureLoadScheduled) return;
    _ensureLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLoadScheduled = false;
      if (!mounted || !_scrollController.hasClients) return;

      final current =
          ref.read(scanUniqidsProductsProvider(_providerKey)).asData?.value;
      if (current == null || !current.hasMore || current.isLoadingMore) return;

      if (_scrollController.position.maxScrollExtent <= 0) {
        ref
            .read(scanUniqidsProductsProvider(_providerKey).notifier)
            .loadMoreWhenViewportNotFilled();
      }
    });
  }

  @override
  void dispose() {
    _addToCartFlowEpoch++;
    _addToCartSubmitting.clear();
    _productsSubscription.close();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _cancelInFlightAddToCartFlow() {
    _addToCartFlowEpoch++;
    if (_addToCartSubmitting.isEmpty) return;
    if (mounted) {
      setState(() => _addToCartSubmitting.clear());
    } else {
      _addToCartSubmitting.clear();
    }
  }

  Future<void> _onProductGridRefresh() async {
    _cancelInFlightAddToCartFlow();
    await ref.read(scanUniqidsProductsProvider(_providerKey).notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(scanUniqidsProductsProvider(_providerKey));
    final isTabletUp = context.isTabletUp;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final columns = isTabletUp ? (isLandscape ? 4 : 3) : 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.productScanUniqidsListTitle),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 34 : 16,
          vertical: 12,
        ),
        child: ProductGridSection(
          productsState: productsState,
          columns: columns,
          scrollController: _scrollController,
          collectOverrides: _collectOverrides,
          collectSubmitting: _collectSubmitting,
          addToCartSubmitting: _addToCartSubmitting,
          onCollectTap: _onCollectTapped,
          onAddToCartTap: _onAddToCartTapped,
          onBeforeNavigateToDetail: _cancelInFlightAddToCartFlow,
          onRetry: _onProductGridRefresh,
          onRefresh: _onProductGridRefresh,
          onEnsureLoadMore: _ensureScrollableAndLoadMoreIfNeeded,
        ),
      ),
    );
  }

  Future<void> _onCollectTapped(ProductItem product) async {
    _cancelInFlightAddToCartFlow();
    final productId = product.id;
    if (_collectSubmitting.contains(productId)) return;
    final hasOverride = _collectOverrides.containsKey(productId);
    final previous = _collectOverrides[productId];
    final current = _collectOverrides[productId] ?? product.isCollect;
    final target = !current;

    setState(() {
      _collectSubmitting.add(productId);
      _collectOverrides[productId] = target;
    });

    final result = target
        ? await createFavorService(productId: productId)
        : await deleteFavorService(productId: productId);

    if (!mounted) return;

    result.when(
      success: (_) {
        ref.invalidate(favoriteProductsProvider);
      },
      failure: (exception) {
        setState(() {
          if (hasOverride && previous != null) {
            _collectOverrides[productId] = previous;
          } else {
            _collectOverrides.remove(productId);
          }
        });
        debugPrint(
          '[scan_uniqids_list] collect failed, productId=$productId, '
          'error=${exception.message}',
        );
      },
    );

    setState(() => _collectSubmitting.remove(productId));
  }

  Future<void> _onAddToCartTapped(ProductItem product) async {
    final productId = product.id;

    final session = ref.read(sessionControllerProvider).asData?.value;
    if (session?.isAuthenticated != true) {
      if (!mounted) return;
      showGlobalWarningMessage(
        context.l10n.cartAddRequireLogin,
        context: context,
      );
      context.go(AppRoutes.login);
      return;
    }

    _cancelInFlightAddToCartFlow();
    final epoch = _addToCartFlowEpoch;
    setState(() => _addToCartSubmitting.add(productId));
    try {
      final detail = await ref.read(productDetailProvider(productId).future);
      if (!mounted) {
        _addToCartSubmitting.remove(productId);
        return;
      }
      if (epoch != _addToCartFlowEpoch) {
        setState(() => _addToCartSubmitting.remove(productId));
        return;
      }
      setState(() => _addToCartSubmitting.remove(productId));

      int? submittedSmId;
      final added = await presentProductSkuCartSideSheet(
        context: context,
        detail: detail,
        showMainImage: true,
        mode: ProductSkuCartSheetMode.addToCart,
        onSubmit: (sheetContext, payload) async {
          final space = await resolveSpaceForCartAdd(sheetContext);
          if (space == null) return false;
          final result = await ref
              .read(cartControllerProvider.notifier)
              .createCartItem(
                productId: payload.apiProductId,
                subIndex: payload.subIndex,
                sIndex: payload.sIndex,
                productNum: payload.productNum,
                space: space,
                subName: payload.subName,
              );
          submittedSmId = await resolveCreateCartItemSubmitSuccess(result);
          return submittedSmId != null;
        },
      );
      if (!mounted) return;
      if (epoch != _addToCartFlowEpoch) return;
      if (added && submittedSmId != null) {
        showGlobalSnackBar(
          buildAddToCartSuccessMessage(
            l10n: context.l10n,
            productTitle: product.name,
            smId: submittedSmId!,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _addToCartSubmitting.remove(productId));
        showGlobalErrorMessage(context.l10n.productDetailLoadFailed('$e'));
      } else {
        _addToCartSubmitting.remove(productId);
      }
    }
  }
}
