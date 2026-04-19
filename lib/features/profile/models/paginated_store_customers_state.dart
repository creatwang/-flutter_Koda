import 'package:groe_app_pad/features/profile/models/store_customer_item_dto.dart';

/// 客户列表分页状态。
class PaginatedStoreCustomersState {
  const PaginatedStoreCustomersState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.totalCount,
  });

  final List<StoreCustomerItemDto> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final int? totalCount;

  PaginatedStoreCustomersState copyWith({
    List<StoreCustomerItemDto>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    int? totalCount,
  }) {
    return PaginatedStoreCustomersState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
