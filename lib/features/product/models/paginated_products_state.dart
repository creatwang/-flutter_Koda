import 'package:george_pick_mate/features/product/models/product_item.dart';

class PaginatedProductsState {
  const PaginatedProductsState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.totalCount,
  });

  final List<ProductItem> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final int? totalCount;

  PaginatedProductsState copyWith({
    List<ProductItem>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    int? totalCount,
  }) {
    return PaginatedProductsState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
