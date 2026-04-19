import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:groe_app_pad/features/cart/controllers/cart_providers.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_card.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_sku_cart_side_sheet_widget.dart';
import 'package:groe_app_pad/features/product/services/product_services.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class ProfileFavoritesSectionWidget extends ConsumerStatefulWidget {
  const ProfileFavoritesSectionWidget({super.key});

  @override
  ConsumerState<ProfileFavoritesSectionWidget> createState() =>
      _ProfileFavoritesSectionWidgetState();
}

class _ProfileFavoritesSectionWidgetState
    extends ConsumerState<ProfileFavoritesSectionWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _collectOverrides = <int, bool>{};
  final Set<int> _collectSubmitting = <int>{};
  final Set<int> _addToCartSubmitting = <int>{};
  int _addToCartFlowEpoch = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _addToCartFlowEpoch++;
    _addToCartSubmitting.clear();
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 320) {
      ref.read(favoriteProductsProvider.notifier).loadMore();
    }
  }

  Future<void> _onCollectTap(ProductItem product) async {
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
        ref.read(favoritesRevisionProvider.notifier).bump();
      },
      failure: (_) {
        setState(() {
          if (hasOverride && previous != null) {
            _collectOverrides[productId] = previous;
          } else {
            _collectOverrides.remove(productId);
          }
        });
      },
    );

    if (!mounted) return;
    setState(() => _collectSubmitting.remove(productId));
  }

  Future<void> _onAddToCartTap(ProductItem product) async {
    final productId = product.id;

    final session = ref.read(sessionControllerProvider).asData?.value;
    if (session?.isAuthenticated != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.cartAddRequireLogin)));
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

      final added = await presentProductSkuCartSideSheet(
        context: context,
        detail: detail,
        showMainImage: true,
        mode: ProductSkuCartSheetMode.addToCart,
        onSubmit: (sheetContext, payload) async {
          final space = await resolveSpaceForCartAdd(sheetContext);
          if (space == null) return false;
          return ref
              .read(cartControllerProvider.notifier)
              .createCartItem(
                productId: payload.apiProductId,
                subIndex: payload.subIndex,
                productNum: payload.productNum,
                space: space,
                subName: payload.subName,
              );
        },
      );
      if (!mounted) return;
      if (epoch != _addToCartFlowEpoch) return;
      if (added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.productAddedToCart(product.name)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _addToCartSubmitting.remove(productId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.productDetailLoadFailed('$e'))),
        );
      } else {
        _addToCartSubmitting.remove(productId);
      }
    }
  }

  Future<void> _onRefreshFavorites() async {
    _cancelInFlightAddToCartFlow();
    _clearCollectState();
    await ref.read(favoriteProductsProvider.notifier).refresh();
  }

  void _clearCollectState() {
    if (!mounted) return;
    setState(() {
      _collectOverrides.clear();
      _collectSubmitting.clear();
      _addToCartSubmitting.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoriteProductsProvider);
    return favoritesState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) =>
          AppErrorView(message: error.toString(), onRetry: _onRefreshFavorites),
      data: (state) {
        if (state.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefreshFavorites,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                AppEmptyView(message: 'Favorites is empty'),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _onRefreshFavorites,
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.76,
            ),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final product = state.items[index];
              final isCollected =
                  _collectOverrides[product.id] ?? product.isCollect;
              return ProductCard(
                key: ValueKey<int>(product.id),
                productItem: product,
                isCollected: isCollected,
                isCollectSubmitting: _collectSubmitting.contains(product.id),
                isAddToCartSubmitting: _addToCartSubmitting.contains(
                  product.id,
                ),
                onCollectTap: () => _onCollectTap(product),
                onAddToCartTap: () => _onAddToCartTap(product),
                onBeforeNavigateToDetail: _cancelInFlightAddToCartFlow,
              );
            },
          ),
        );
      },
    );
  }
}
