import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/product/models/paginated_products_state.dart';
import 'package:groe_app_pad/features/product/models/product_category_tree_dto.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/services/product_services.dart';

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, PaginatedProductsState>(
      ProductsNotifier.new,
    );

final favoritesRevisionProvider =
    NotifierProvider<FavoritesRevisionNotifier, int>(
      FavoritesRevisionNotifier.new,
    );

final favoriteProductsProvider =
    AsyncNotifierProvider<FavoriteProductsNotifier, PaginatedProductsState>(
      FavoriteProductsNotifier.new,
    );

class ProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  static const int _pageSize = 8;
  int _selectedShopCategoryId = 0;
  String? _sort;
  int _orderBy = 0;

  @override
  FutureOr<PaginatedProductsState> build() async {
    final result = await fetchProductsPageService(
      page: 1,
      pageSize: _pageSize,
      shopCateGoryId: _selectedShopCategoryId,
      sort: _sort,
      orderBy: _orderBy,
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
        shopCateGoryId: _selectedShopCategoryId,
        sort: _sort,
        orderBy: _orderBy,
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
      shopCateGoryId: _selectedShopCategoryId,
      sort: _sort,
      orderBy: _orderBy,
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

  Future<void> applyCategoryFilter(
    int? categoryId, {
    String? sort,
    int? orderBy,
  }) async {
    _selectedShopCategoryId = categoryId ?? 0;
    _sort = sort ?? _sort;
    _orderBy = orderBy ?? _orderBy;
    await refresh();
  }

  Future<void> applySort({String? sort, int orderBy = 0}) async {
    _sort = sort;
    _orderBy = orderBy;
    await refresh();
  }
}

class FavoritesRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

class FavoriteProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  static const int _pageSize = 20;

  @override
  FutureOr<PaginatedProductsState> build() async {
    ref.watch(favoritesRevisionProvider);
    final result = await fetchFavorProductsPageService(
      page: 1,
      pageSize: _pageSize,
    );
    return result.when(
      success: (data) => PaginatedProductsState(
        items: data.items,
        page: 1,
        hasMore: data.items.length >= _pageSize,
        totalCount: data.total,
      ),
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchFavorProductsPageService(
        page: 1,
        pageSize: _pageSize,
      );
      return result.when(
        success: (data) => PaginatedProductsState(
          items: data.items,
          page: 1,
          hasMore: data.items.length >= _pageSize,
          totalCount: data.total,
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
    final result = await fetchFavorProductsPageService(
      page: nextPage,
      pageSize: _pageSize,
    );
    state = result.when(
      success: (allData) {
        final oldIds = current.items.map((e) => e.id).toSet();
        final delta = allData.items
            .where((e) => !oldIds.contains(e.id))
            .toList();
        final merged = [...current.items, ...delta];
        return AsyncData(
          current.copyWith(
            items: merged,
            page: nextPage,
            hasMore: delta.isNotEmpty && merged.length < allData.total,
            isLoadingMore: false,
            totalCount: allData.total,
          ),
        );
      },
      failure: (exception) => AsyncError(exception, StackTrace.current),
    );
  }
}

final productByIdProvider = FutureProvider.family<ProductItem, int>((
  ref,
  id,
) async {
  final result = await fetchProductByIdService(id);
  return result.when(
    success: (data) => data,
    failure: (exception) => throw exception,
  );
});

final productDetailProvider = FutureProvider.family<ProductDetailDto, int>((
  ref,
  id,
) async {
  final result = await fetchProductDetailService(id);
  return result.when(
    success: (data) => data,
    failure: (exception) => throw exception,
  );
});

final categoryTreeProvider = FutureProvider<List<ProductCategoryTreeDto>>((
  ref,
) async {
  final result = await fetchCategoryTreeService();
  return result.when(
    success: (data) => data,
    failure: (exception) => throw exception,
  );
});
