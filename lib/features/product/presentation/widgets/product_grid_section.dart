import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/product/models/paginated_products_state.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_card.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class ProductGridSection extends StatelessWidget {
  const ProductGridSection({
    required this.productsState,
    required this.columns,
    required this.scrollController,
    required this.collectOverrides,
    required this.collectSubmitting,
    required this.onCollectTap,
    required this.onRetry,
    required this.onRefresh,
    required this.onEnsureLoadMore,
    super.key,
  });

  final AsyncValue<PaginatedProductsState> productsState;
  final int columns;
  final ScrollController scrollController;
  final Map<int, bool> collectOverrides;
  final Set<int> collectSubmitting;
  final ValueChanged<ProductItem> onCollectTap;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onEnsureLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return productsState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(
        message: l10n.productLoadFailed(error.toString()),
        onRetry: onRetry,
      ),
      data: (items) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: items.items.isEmpty
              ? AppEmptyView(message: l10n.productEmpty)
              : Builder(
                  builder: (_) {
                    onEnsureLoadMore();
                    return GridView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.76,
                      ),
                      itemCount: items.items.length + (items.isLoadingMore ? 1 : 0),
                      itemBuilder: (_, index) {
                        if (index >= items.items.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final product = items.items[index];
                        final isCollected = collectOverrides[product.id] ?? product.isCollect;
                        return ProductCard(
                          productItem: product,
                          isCollected: isCollected,
                          isCollectSubmitting: collectSubmitting.contains(product.id),
                          onCollectTap: () => onCollectTap(product),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
