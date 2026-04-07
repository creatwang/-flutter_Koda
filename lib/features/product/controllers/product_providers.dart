import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/product/models/paginated_products_state.dart';
import 'package:groe_app_pad/features/product/models/product.dart';
import 'package:groe_app_pad/features/product/services/product_services.dart';

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, PaginatedProductsState>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  static const int _pageSize = 8;

  @override
  FutureOr<PaginatedProductsState> build() async {
    final result = await fetchProductsPageService(
      page: 1,
      pageSize: _pageSize,
    );
    return result.when(
      success: (data) => PaginatedProductsState(
        items: data,
        page: 1,
        hasMore: data.length >= _pageSize,
      ),
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchProductsPageService(
        page: 1,
        pageSize: _pageSize,
      );
      return result.when(
        success: (data) => PaginatedProductsState(
          items: data,
          page: 1,
          hasMore: data.length >= _pageSize,
        ),
        failure: (exception) => throw exception,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await fetchProductsPageService(
      page: nextPage,
      pageSize: _pageSize,
    );

    state = result.when(
      success: (allData) {
        final oldIds = current.items.map((e) => e.id).toSet();
        final delta = allData.where((e) => !oldIds.contains(e.id)).toList();
        final merged = [...current.items, ...delta];
        return AsyncData(
          current.copyWith(
            items: merged,
            page: nextPage,
            hasMore: delta.isNotEmpty && allData.length >= _pageSize,
            isLoadingMore: false,
          ),
        );
      },
      failure: (exception) => AsyncError(exception, StackTrace.current),
    );
  }
}

final productByIdProvider = FutureProvider.family<Product, int>((ref, id) async {
  final result = await fetchProductByIdService(id);
  return result.when(
    success: (data) => data,
    failure: (exception) => throw exception,
  );
});
