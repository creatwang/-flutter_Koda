import 'package:george_pick_mate/features/product/models/product_category_tree_dto.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_list_sort_header.dart';

/// 商品列表页纯 UI 状态：侧栏分类、排序、侧栏折叠（无网络逻辑）。
class ProductListController {
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
    return sortByQueryMap[selectedSortValue] ??
        const SortQuery(sort: null, orderBy: 0);
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

  void toggleSidebar() => isFilterCollapsed = !isFilterCollapsed;

  void collapseSidebar() => isFilterCollapsed = true;
}
