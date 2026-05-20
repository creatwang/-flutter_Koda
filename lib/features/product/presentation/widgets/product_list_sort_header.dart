import 'package:flutter/material.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_checkbox_button.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';

class SortOption {
  const SortOption({
    required this.text,
    required this.value,
  });

  final String text;
  final int value;
}

class SortQuery {
  const SortQuery({
    required this.sort,
    required this.orderBy,
  });

  final String? sort;
  final int orderBy;
}

String sortLabelForValue(AppLocalizations l10n, int value) {
  return switch (value) {
    1 => l10n.productSortPriceLowHigh,
    2 => l10n.productSortPriceHighLow,
    3 => l10n.productSortRatingHighest,
    4 => l10n.productSortRatingLowest,
    5 => l10n.productSortModelAz,
    6 => l10n.productSortModelZa,
    7 => l10n.productSortDateOldNew,
    8 => l10n.productSortDateNewOld,
    _ => l10n.productSortDefault,
  };
}

List<SortOption> buildSortByOptions(AppLocalizations l10n) {
  return <SortOption>[
    SortOption(text: l10n.productSortDefault, value: 0),
    SortOption(text: l10n.productSortPriceLowHigh, value: 1),
    SortOption(text: l10n.productSortPriceHighLow, value: 2),
    SortOption(text: l10n.productSortRatingHighest, value: 3),
    SortOption(text: l10n.productSortRatingLowest, value: 4),
    SortOption(text: l10n.productSortModelAz, value: 5),
    SortOption(text: l10n.productSortModelZa, value: 6),
    SortOption(text: l10n.productSortDateOldNew, value: 7),
    SortOption(text: l10n.productSortDateNewOld, value: 8),
  ];
}

const Map<int, SortQuery> sortByQueryMap = <int, SortQuery>{
  0: SortQuery(sort: null, orderBy: 0),
  1: SortQuery(sort: 'asc', orderBy: 1),
  2: SortQuery(sort: 'desc', orderBy: 1),
  3: SortQuery(sort: 'desc', orderBy: 2),
  4: SortQuery(sort: 'asc', orderBy: 2),
  5: SortQuery(sort: 'asc', orderBy: 3),
  6: SortQuery(sort: 'desc', orderBy: 3),
  7: SortQuery(sort: 'asc', orderBy: 4),
  8: SortQuery(sort: 'desc', orderBy: 4),
};

class ProductSortHeader extends StatelessWidget {
  const ProductSortHeader({
    required this.selectedSortValue,
    required this.selectedSortLabel,
    required this.onSortChanged,
    required this.isSidebarCollapsed,
    this.onToggleSidebar,
    this.onOpenFilters,
    this.inShowroomSelected = false,
    this.onInShowroomChanged,
    this.searchKeywordController,
    this.onSearchPressed,
    super.key,
  });

  final int selectedSortValue;
  final String selectedSortLabel;
  final ValueChanged<int> onSortChanged;
  final bool isSidebarCollapsed;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onOpenFilters;

  /// 「In Showroom」筛选（与 [onInShowroomChanged] 成对出现）。
  final bool inShowroomSelected;
  final ValueChanged<bool>? onInShowroomChanged;

  /// 关键词搜索（与 [onSearchPressed] 成对出现，插在展厅筛选与排序之间）。
  /// 键盘「搜索」与清空按钮都会触发 [onSearchPressed]。
  final TextEditingController? searchKeywordController;
  final VoidCallback? onSearchPressed;

  Widget _buildExpandSidebarButton(BuildContext context) {
    final l10n = context.l10n;
    return Tooltip(
      message: l10n.productExpandFilterSidebar,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onToggleSidebar,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: const Icon(
            Icons.keyboard_double_arrow_right,
            color: Colors.white70,
            size: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSortControl(
    BuildContext context, {
    required bool compact,
  }) {
    final l10n = context.l10n;
    final sortOptions = buildSortByOptions(l10n);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: SizedBox(
        height: 40,
        width: 180,
        child: PopupMenuButton<int>(
          tooltip: '',
          padding: EdgeInsets.zero,
          initialValue: selectedSortValue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFF2B2F34),
          onSelected: onSortChanged,
          itemBuilder: (context) => sortOptions
              .map(
                (e) => PopupMenuItem<int>(
                  value: e.value,
                  height: 36,
                  child: Text(
                    e.text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.sort, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    compact
                        ? selectedSortLabel
                        : l10n.productSortBy(selectedSortLabel),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, size: 16, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInShowroomToggle(
    BuildContext context, {
    required bool compact,
  }) {
    final l10n = context.l10n;
    final onChanged = onInShowroomChanged;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GeorgeCheckboxButton(
          value: inShowroomSelected,
          touchExtent: 30,
          borderColor: Colors.white54,
          checkedFillColor: Colors.white.withValues(alpha: 0.35),
          checkColor: Colors.white,
          semanticLabel: l10n.productInShowroom,
          onChanged: onChanged,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onChanged == null
              ? null
              : () => onChanged(!inShowroomSelected),
          child: Padding(
            padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
            child: Text(
              l10n.productInShowroom,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordSearch(
    BuildContext context, {
    required bool compact,
    required TextEditingController controller,
    required VoidCallback onSearchSubmitted,
  }) {
    final l10n = context.l10n;
    final hintSize = compact ? 11.0 : 12.0;
    final iconSize = compact ? 14.0 : 15.0;
    return Container(
      height: 40,
      constraints: BoxConstraints(
        minWidth: compact ? 140 : 200,
        maxWidth: compact ? 240 : 340,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: hintSize,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Colors.white70,
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.productSearchHint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: hintSize,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearchSubmitted(),
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final hasText = controller.text.trim().isNotEmpty;
              if (!hasText) {
                return const SizedBox(width: 4);
              }
              return Padding(
                padding: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  child: Tooltip(
                    message: l10n.productClearSearch,
                    child: InkWell(
                      onTap: () {
                        controller.clear();
                        onSearchSubmitted();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 4 : 5),
                        child: Icon(
                          Icons.close,
                          size: iconSize,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1180;
        final searchController = searchKeywordController;
        final searchAction = onSearchPressed;
        return Row(
          children: [
            if (isSidebarCollapsed && onToggleSidebar != null) ...[
              _buildExpandSidebarButton(context),
              const SizedBox(width: 8),
            ],
            Container(
              child: Text(
                l10n.productLibrary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 24,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onOpenFilters != null) ...[
                        compact
                            ? IconButton(
                                onPressed: onOpenFilters,
                                tooltip: l10n.productFilters,
                                icon: const Icon(Icons.tune),
                              )
                            : OutlinedButton.icon(
                                onPressed: onOpenFilters,
                                icon: const Icon(Icons.tune),
                                label: Text(l10n.productFilters),
                              ),
                        const SizedBox(width: 8),
                      ],
                      if (onInShowroomChanged != null) ...[
                        _buildInShowroomToggle(context, compact: compact),
                        const SizedBox(width: 8),
                      ],
                      if (searchController != null &&
                          searchAction != null) ...[
                        _buildKeywordSearch(
                          context,
                          compact: compact,
                          controller: searchController,
                          onSearchSubmitted: searchAction,
                        ),
                        const SizedBox(width: 8),
                      ],
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: compact ? 140 : 220,
                          maxWidth: compact ? 220 : 320,
                        ),
                        child: _buildSortControl(context, compact: compact),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
