import 'package:groe_app_pad/features/product/domain/entities/product.dart';

class PaginatedProductsState {
  const PaginatedProductsState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Product> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedProductsState copyWith({
    List<Product>? items,
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
