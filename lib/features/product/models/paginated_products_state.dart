import 'package:groe_app_pad/features/product/models/product_item.dart';

class PaginatedProductsState {
  const PaginatedProductsState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<ProductItem> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedProductsState copyWith({
    List<ProductItem>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedProductsState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
