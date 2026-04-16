import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_card.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 320) {
      ref.read(favoriteProductsProvider.notifier).loadMore();
    }
  }

  Future<void> _onCollectTap(ProductItem product) async {
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
      success: (_) async {
        ref.read(favoritesRevisionProvider.notifier).bump();
        await ref.read(favoriteProductsProvider.notifier).refresh();
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

  void _onAddToCartTap(ProductItem product) {
    ref.read(cartControllerProvider.notifier).addProduct(product);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.productAddedToCart(product.name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoriteProductsProvider);
    return favoritesState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(
        message: error.toString(),
        onRetry: () => ref.read(favoriteProductsProvider.notifier).refresh(),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return const AppEmptyView(message: 'Favorites is empty');
        }
        return GridView.builder(
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
              onCollectTap: () => _onCollectTap(product),
              onAddToCartTap: () => _onAddToCartTap(product),
            );
          },
        );
      },
    );
  }
}
