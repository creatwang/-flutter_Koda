import 'package:flutter/material.dart';

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

const List<SortOption> sortByOptions = <SortOption>[
  SortOption(text: 'Default', value: 0),
  SortOption(text: 'Price(Low > High)', value: 1),
  SortOption(text: 'Price(Low < High)', value: 2),
  SortOption(text: 'Rating(Highest)', value: 3),
  SortOption(text: 'Rating(Lowest)', value: 4),
  SortOption(text: 'Model(A - Z)', value: 5),
  SortOption(text: 'Model(Z - A)', value: 6),
];

const Map<int, SortQuery> sortByQueryMap = <int, SortQuery>{
  0: SortQuery(sort: null, orderBy: 0),
  1: SortQuery(sort: 'asc', orderBy: 1),
  2: SortQuery(sort: 'desc', orderBy: 1),
  3: SortQuery(sort: 'desc', orderBy: 2),
  4: SortQuery(sort: 'asc', orderBy: 2),
  5: SortQuery(sort: 'asc', orderBy: 3),
  6: SortQuery(sort: 'desc', orderBy: 3),
};

class ProductSortHeader extends StatelessWidget {
  const ProductSortHeader({
    required this.selectedSortValue,
    required this.selectedSortLabel,
    required this.onSortChanged,
    required this.isSidebarCollapsed,
    this.onToggleSidebar,
    this.onOpenFilters,
    super.key,
  });

  final int selectedSortValue;
  final String selectedSortLabel;
  final ValueChanged<int> onSortChanged;
  final bool isSidebarCollapsed;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onOpenFilters;

  Widget _buildExpandSidebarButton() {
    return Tooltip(
      message: '展开筛选侧边栏',
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
            size: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSortControl({
    required bool compact,
  }) {
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
          itemBuilder: (context) => sortByOptions
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
                    compact ? selectedSortLabel : 'Sort by: $selectedSortLabel',
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1180;
        return Row(
          children: [
            if (isSidebarCollapsed && onToggleSidebar != null) ...[
              _buildExpandSidebarButton(),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                'Curated Product Library',
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
                                tooltip: 'Filters',
                                icon: const Icon(Icons.tune),
                              )
                            : OutlinedButton.icon(
                                onPressed: onOpenFilters,
                                icon: const Icon(Icons.tune),
                                label: const Text('Filters'),
                              ),
                        const SizedBox(width: 8),
                      ],
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: compact ? 140 : 220,
                          maxWidth: compact ? 220 : 320,
                        ),
                        child: _buildSortControl(compact: compact),
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
