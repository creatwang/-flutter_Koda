// 商品列表、收藏、详情与分类树的 Riverpod 数据源。

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/product/models/paginated_products_state.dart';
import 'package:george_pick_mate/features/product/models/product_category_tree_dto.dart';
import 'package:george_pick_mate/features/product/models/product_detail_dto.dart';
import 'package:george_pick_mate/features/product/services/product_services.dart';

/// 商品列表分页（含排序、分类筛选状态）。
final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, PaginatedProductsState>(
      ProductsNotifier.new,
    );

/// 收藏商品分页状态。
final favoriteProductsProvider =
    AsyncNotifierProvider<FavoriteProductsNotifier, PaginatedProductsState>(
      FavoriteProductsNotifier.new,
    );

/// 维护商品列表的加载、刷新、加载更多与筛选参数。
class ProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  static const int _pageSize = 8;
  int _selectedShopCategoryId = 0;
  String? _sort;
  int _orderBy = 0;
  bool _onlyShowroomSample = false;
  String _keyword = '';
  int _queryVersion = 0;

  @override
  FutureOr<PaginatedProductsState> build() async {
    _queryVersion++;
    final result = await fetchProductsPageService(
      page: 1,
      pageSize: _pageSize,
      shopCateGoryId: _selectedShopCategoryId,
      sort: _sort,
      orderBy: _orderBy,
      onlyShowroomSample: _onlyShowroomSample,
      keyword: _keyword.isEmpty ? null : _keyword,
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
    _queryVersion++;
    final version = _queryVersion;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await fetchProductsPageService(
        page: 1,
        pageSize: _pageSize,
        shopCateGoryId: _selectedShopCategoryId,
        sort: _sort,
        orderBy: _orderBy,
        onlyShowroomSample: _onlyShowroomSample,
        keyword: _keyword.isEmpty ? null : _keyword,
      );
      if (version != _queryVersion) {
        throw StateError('Stale products refresh response');
      }
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

  Future<void> loadMoreOnScroll() => _loadMoreNextPage();

  Future<void> loadMoreWhenViewportNotFilled() => _loadMoreNextPage();

  Future<void> _loadMoreNextPage() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final version = _queryVersion;
    final selectedShopCategoryId = _selectedShopCategoryId;
    final sort = _sort;
    final orderBy = _orderBy;
    final onlyShowroomSample = _onlyShowroomSample;
    final keyword = _keyword.isEmpty ? null : _keyword;
    final result = await fetchProductsPageService(
      page: nextPage,
      pageSize: _pageSize,
      shopCateGoryId: selectedShopCategoryId,
      sort: sort,
      orderBy: orderBy,
      onlyShowroomSample: onlyShowroomSample,
      keyword: keyword,
    );
    if (version != _queryVersion) return;

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

  Future<void> applyShowroomSampleFilter(bool onlyShowroomSample) async {
    _onlyShowroomSample = onlyShowroomSample;
    await refresh();
  }

  /// 点击搜索后生效；空字符串表示不传 keyword。
  Future<void> applyKeywordSearch(String keyword) async {
    _keyword = keyword.trim();
    await refresh();
  }
}

/// 收藏商品列表：首屏、刷新、分页加载更多。
class FavoriteProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  static const int _pageSize = 20;

  @override
  FutureOr<PaginatedProductsState> build() async {
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

/// 商品详情 DTO（[id] 为商品 id）。
final productDetailProvider =
    FutureProvider.autoDispose.family<ProductDetailDto, int>((ref, id) async {
  final result = await fetchProductDetailService(id);
  return result.getOrThrow();
});

/// 当前站点商品分类树。
final categoryTreeProvider = FutureProvider<List<ProductCategoryTreeDto>>((
  ref,
) async {
  final result = await fetchCategoryTreeService();
  return result.getOrThrow();
});
