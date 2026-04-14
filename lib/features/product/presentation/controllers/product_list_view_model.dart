import 'package:groe_app_pad/features/product/models/product_category_tree_dto.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_list_sort_header.dart';

class ProductListViewModel {
  int? selectedCategoryId;
  String selectedCategoryLabel = '';
  int selectedSortValue = 0;
  bool isFilterCollapsed = false;

  SortOption get currentSortOption {
    return sortByOptions.firstWhere(
      (e) => e.value == selectedSortValue,
      orElse: () => sortByOptions.first,
    );
  }

  SortQuery get currentSortQuery {
    return sortByQueryMap[selectedSortValue] ?? const SortQuery(sort: null, orderBy: 0);
  }

  void setSortValue(int value) {
    final option = sortByOptions.firstWhere(
      (e) => e.value == value,
      orElse: () => sortByOptions.first,
    );
    selectedSortValue = option.value;
  }

  void toggleCategory(ProductCategoryTreeDto category) {
    final id = category.id;
    if (id == null) return;
    final isSameCategory = selectedCategoryId == id;
    selectedCategoryId = isSameCategory ? null : id;
    selectedCategoryLabel = isSameCategory ? '' : (category.name ?? '');
  }

  void toggleSidebar() {
    isFilterCollapsed = !isFilterCollapsed;
  }

  void collapseSidebar() {
    isFilterCollapsed = true;
  }

  String buildSearchLog({required String trigger}) {
    return '[product_list] trigger=$trigger, sortValue=$selectedSortValue, '
        'sort=${currentSortQuery.sort ?? 'null'}, order_by=${currentSortQuery.orderBy}, '
        'shopCateGoryId=${selectedCategoryId ?? 0}, '
        'categoryLabel=${selectedCategoryLabel.isEmpty ? 'none' : selectedCategoryLabel}';
  }
}
