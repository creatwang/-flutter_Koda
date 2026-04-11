import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_card.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({
    this.onSortChanged,
    this.onApplyFilters,
    this.onPriceRangeChanged,
    this.onBrandSelectionChanged,
    this.onCategoryChanged,
    this.onSubCategoryChanged,
    super.key,
  });

  final ValueChanged<String>? onSortChanged;
  final VoidCallback? onApplyFilters;
  final ValueChanged<RangeValues>? onPriceRangeChanged;
  final ValueChanged<Set<String>>? onBrandSelectionChanged;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onSubCategoryChanged;

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _ensureLoadScheduled = false;
  RangeValues _priceRange = const RangeValues(0, 50000);
  final Set<String> _selectedBrands = <String>{'B&B Italia'};
  String _selectedCategory = 'Furniture';
  String _selectedSubCategory = 'Sofas';
  String _selectedLeafCategory = 'All Sofas';
  String _selectedSort = 'Curation Popularity';
  bool _lightingExpanded = false;
  bool _artExpanded = false;
  bool _furnitureExpanded = true;
  bool _sofasExpanded = true;
  bool _isFilterCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 300) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  void _ensureScrollableAndLoadMoreIfNeeded() {
    if (_ensureLoadScheduled) return;
    _ensureLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLoadScheduled = false;
      if (!mounted || !_scrollController.hasClients) return;

      final current = ref.read(productsProvider).asData?.value;
      if (current == null || !current.hasMore || current.isLoadingMore) return;

      // 内容不足一屏时（无法滚动到底），主动触发下一页加载。
      if (_scrollController.position.maxScrollExtent <= 0) {
        ref.read(productsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final productsState = ref.watch(productsProvider);
    final isTabletUp = context.isTabletUp;
    final columns = isTabletUp ? (_isFilterCollapsed ? 5 : 4) : 2;

    return productsState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(
        message: l10n.productLoadFailed(error.toString()),
        onRetry: () => ref.read(productsProvider.notifier).refresh(),
      ),
      data: (items) {
        if (items.items.isEmpty) return AppEmptyView(message: l10n.productEmpty);
        _ensureScrollableAndLoadMoreIfNeeded();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isTabletUp)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  width: _isFilterCollapsed ? 0 : 282,
                  child: ClipRect(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _isFilterCollapsed ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: _isFilterCollapsed,
                        child: Row(
                          children: [
                            Expanded(
                              child: _FilterPanel(
                                selectedCategory: _selectedCategory,
                                selectedSubCategory: _selectedSubCategory,
                                selectedBrands: _selectedBrands,
                                priceRange: _priceRange,
                                lightingExpanded: _lightingExpanded,
                                artExpanded: _artExpanded,
                                furnitureExpanded: _furnitureExpanded,
                                sofasExpanded: _sofasExpanded,
                                selectedLeafCategory: _selectedLeafCategory,
                                onFurnitureTap: _onFurnitureTap,
                                onSubCategoryTap: _onSubCategoryTap,
                                onLeafCategoryTap: _onLeafCategoryTap,
                                onPriceChanged: _onPriceChanged,
                                onBrandToggle: _onBrandToggle,
                                onApplyTap: _onApplyTap,
                                onCollapseTap: () => setState(() => _isFilterCollapsed = true),
                                onLightingExpandedChanged: (v) => setState(() => _lightingExpanded = v),
                                onArtExpandedChanged: (v) => setState(() => _artExpanded = v),
                                pinApplyButtonToBottom: true,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    _SortHeader(
                      selectedSort: _selectedSort,
                      onSortChanged: _onSortChanged,
                      isSidebarCollapsed: _isFilterCollapsed,
                      onToggleSidebar: isTabletUp
                          ? () => setState(() => _isFilterCollapsed = !_isFilterCollapsed)
                          : null,
                      onOpenFilters: isTabletUp ? null : _openMobileFilterSheet,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref.read(productsProvider.notifier).refresh(),
                        child: GridView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.73,
                          ),
                          itemCount: items.items.length + (items.isLoadingMore ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index >= items.items.length) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return ProductCard(productItem: items.items[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSortChanged(String value) {
    setState(() => _selectedSort = value);
  }

  void _onApplyTap() {
    _logSearchParams(trigger: 'apply_filters');
    widget.onSortChanged?.call(_selectedSort);
    widget.onCategoryChanged?.call(_selectedCategory);
    widget.onSubCategoryChanged?.call(_selectedSubCategory);
    widget.onPriceRangeChanged?.call(_priceRange);
    widget.onBrandSelectionChanged?.call(_selectedBrands);
    widget.onApplyFilters?.call();
  }

  void _onPriceChanged(RangeValues values) {
    setState(() => _priceRange = values);
  }

  void _onBrandToggle(String brand, bool selected) {
    setState(() {
      if (selected) {
        _selectedBrands.add(brand);
      } else {
        _selectedBrands.remove(brand);
      }
    });
  }

  void _onFurnitureTap() {
    setState(() {
      if (_selectedCategory != 'Furniture') {
        _selectedCategory = 'Furniture';
        _furnitureExpanded = true;
      } else {
        _furnitureExpanded = !_furnitureExpanded;
      }
      if (!_furnitureExpanded) _sofasExpanded = false;
    });
  }

  void _onSubCategoryTap(String value) {
    setState(() {
      if (value == 'Sofas') {
        if (_selectedSubCategory != 'Sofas') {
          _selectedSubCategory = 'Sofas';
          _sofasExpanded = true;
        } else {
          _sofasExpanded = !_sofasExpanded;
        }
      } else {
        _selectedSubCategory = value;
        _sofasExpanded = false;
        _selectedLeafCategory = 'All Sofas';
      }
    });
  }

  void _onLeafCategoryTap(String value) {
    setState(() => _selectedLeafCategory = value);
  }

  void _logSearchParams({required String trigger}) {
    debugPrint(
      '[product_list] trigger=$trigger, sort=$_selectedSort, '
      'category=$_selectedCategory, subCategory=$_selectedSubCategory, '
      'leafCategory=$_selectedLeafCategory, '
      'priceStart=${_priceRange.start.toStringAsFixed(0)}, '
      'priceEnd=${_priceRange.end.toStringAsFixed(0)}, '
      'brands=${_selectedBrands.join('|')}',
    );
  }

  Future<void> _openMobileFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: _FilterPanel(
            selectedCategory: _selectedCategory,
            selectedSubCategory: _selectedSubCategory,
            selectedBrands: _selectedBrands,
            priceRange: _priceRange,
            lightingExpanded: _lightingExpanded,
            artExpanded: _artExpanded,
            furnitureExpanded: _furnitureExpanded,
            sofasExpanded: _sofasExpanded,
            selectedLeafCategory: _selectedLeafCategory,
            onFurnitureTap: _onFurnitureTap,
            onSubCategoryTap: _onSubCategoryTap,
            onLeafCategoryTap: _onLeafCategoryTap,
            onPriceChanged: _onPriceChanged,
            onBrandToggle: _onBrandToggle,
            onApplyTap: _onApplyTap,
            onCollapseTap: null,
            onLightingExpandedChanged: (v) => setState(() => _lightingExpanded = v),
            onArtExpandedChanged: (v) => setState(() => _artExpanded = v),
            pinApplyButtonToBottom: false,
          ),
        ),
      ),
    );
  }
}

class _SortHeader extends StatelessWidget {
  const _SortHeader({
    required this.selectedSort,
    required this.onSortChanged,
    required this.isSidebarCollapsed,
    this.onToggleSidebar,
    this.onOpenFilters,
  });

  final String selectedSort;
  final ValueChanged<String> onSortChanged;
  final bool isSidebarCollapsed;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onOpenFilters;

  static const List<String> _sortOptions = <String>[
    'Curation Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              if (isSidebarCollapsed && onToggleSidebar != null) ...[
                Tooltip(
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
                ),
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
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (onOpenFilters != null) ...[
          OutlinedButton.icon(
            onPressed: onOpenFilters,
            icon: const Icon(Icons.tune),
            label: const Text('Filters'),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSort,
              borderRadius: BorderRadius.circular(10),
              icon: const SizedBox.shrink(),
              selectedItemBuilder: (context) => _sortOptions
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            'Sort by: $e',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
              items: _sortOptions
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.selectedLeafCategory,
    required this.selectedBrands,
    required this.priceRange,
    required this.lightingExpanded,
    required this.artExpanded,
    required this.furnitureExpanded,
    required this.sofasExpanded,
    required this.onFurnitureTap,
    required this.onSubCategoryTap,
    required this.onLeafCategoryTap,
    required this.onPriceChanged,
    required this.onBrandToggle,
    required this.onApplyTap,
    required this.onCollapseTap,
    required this.onLightingExpandedChanged,
    required this.onArtExpandedChanged,
    required this.pinApplyButtonToBottom,
  });

  final String selectedCategory;
  final String selectedSubCategory;
  final String selectedLeafCategory;
  final Set<String> selectedBrands;
  final RangeValues priceRange;
  final bool lightingExpanded;
  final bool artExpanded;
  final bool furnitureExpanded;
  final bool sofasExpanded;
  final VoidCallback onFurnitureTap;
  final ValueChanged<String> onSubCategoryTap;
  final ValueChanged<String> onLeafCategoryTap;
  final ValueChanged<RangeValues> onPriceChanged;
  final void Function(String brand, bool selected) onBrandToggle;
  final VoidCallback onApplyTap;
  final VoidCallback? onCollapseTap;
  final ValueChanged<bool> onLightingExpandedChanged;
  final ValueChanged<bool> onArtExpandedChanged;
  final bool pinApplyButtonToBottom;

  @override
  Widget build(BuildContext context) {
    final treeContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterChipButton(
          label: 'Furniture',
          selected: selectedCategory == 'Furniture',
          expanded: furnitureExpanded,
          onTap: onFurnitureTap,
        ),
        _AnimatedExpand(
          expanded: furnitureExpanded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _TreeNodeRow(
                title: 'Sofas',
                expanded: sofasExpanded,
                selected: selectedSubCategory == 'Sofas',
                onTap: () => onSubCategoryTap('Sofas'),
              ),
              _AnimatedExpand(
                expanded: sofasExpanded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <String>['All Sofas', 'Single Seat', 'Modular', 'Leather', 'Fabric']
                          .map(
                            (e) => _TinyTag(
                              label: e,
                              selected: selectedLeafCategory == e,
                              onTap: () => onLeafCategoryTap(e),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TreeNodeRow(
                title: 'Seating',
                expanded: false,
                selected: selectedSubCategory == 'Seating',
                onTap: () => onSubCategoryTap('Seating'),
                dense: true,
              ),
              const SizedBox(height: 4),
              _TreeNodeRow(
                title: 'Tables',
                expanded: false,
                selected: selectedSubCategory == 'Tables',
                onTap: () => onSubCategoryTap('Tables'),
                dense: true,
              ),
            ],
          ),
        ),
      ],
    );

    final filterBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Product Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
              ),
            ),
            if (onCollapseTap != null)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onCollapseTap,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.keyboard_double_arrow_left,
                    size: 13,
                    color: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        treeContent,
        const SizedBox(height: 10),
        _ExpandableFilterTile(
          title: 'Lighting Systems',
          expanded: lightingExpanded,
          onChanged: onLightingExpandedChanged,
        ),
        const SizedBox(height: 8),
        _ExpandableFilterTile(
          title: 'Art & Decor',
          expanded: artExpanded,
          onChanged: onArtExpandedChanged,
        ),
        const SizedBox(height: 14),
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFE3AE2B),
            inactiveTrackColor: const Color(0xFFDCE4F1).withValues(alpha: 0.92),
            overlayColor: const Color(0x30E3AE2B),
            trackHeight: 4,
            rangeThumbShape: const _RingRangeSliderThumbShape(
              ringColor: Color(0xFF003F7F),
              fillColor: Color(0xFFECECEC),
            ),
          ),
          child: RangeSlider(
            values: priceRange,
            min: 0,
            max: 50000,
            labels: RangeLabels(
              '¥${priceRange.start.toInt()}',
              '¥${priceRange.end.toInt()}',
            ),
            onChanged: onPriceChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('¥0', style: TextStyle(color: Colors.white.withValues(alpha: 0.86))),
            Text(
              '¥${_formatYuan(priceRange.end)}+',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.86)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Brand Curation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 6),
        _BrandOptionTile(
          label: 'Hermes Maison',
          selected: selectedBrands.contains('Hermes Maison'),
          onTap: () => onBrandToggle(
            'Hermes Maison',
            !selectedBrands.contains('Hermes Maison'),
          ),
        ),
        const SizedBox(height: 6),
        _BrandOptionTile(
          label: 'B&B Italia',
          selected: selectedBrands.contains('B&B Italia'),
          onTap: () => onBrandToggle('B&B Italia', !selectedBrands.contains('B&B Italia')),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF22262B).withValues(alpha: 0.70),
                const Color(0xFF2B2F34).withValues(alpha: 0.54),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pinApplyButtonToBottom)
                  Expanded(
                    child: SingleChildScrollView(
                      child: filterBody,
                    ),
                  )
                else
                  filterBody,
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onApplyTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA19E9A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatYuan(double value) {
    final valueStr = value.toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < valueStr.length; i++) {
      final reverseIndex = valueStr.length - i;
      buffer.write(valueStr[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? Colors.white.withValues(alpha: 0.26)
              : Colors.white.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              turns: expanded ? 0.5 : 0,
              child: Icon(
                Icons.expand_more,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.26) : Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontSize: 10.5,
                ),
          ),
        ),
      ),
    );
  }
}

class _TreeNodeRow extends StatelessWidget {
  const _TreeNodeRow({
    required this.title,
    required this.selected,
    required this.expanded,
    required this.onTap,
    this.dense = false,
  });

  final String title;
  final bool selected;
  final bool expanded;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 24,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: selected ? 1 : 0.92),
                  fontSize: dense ? 12.5 : 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              turns: expanded ? 0.5 : 0,
              child: Icon(
                Icons.expand_more,
                size: dense ? 13 : 15,
                color: Colors.white.withValues(alpha: 0.74),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandOptionTile extends StatelessWidget {
  const _BrandOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFA7B2E8) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.72), width: 1.4),
            ),
            child: selected
                ? const Icon(Icons.check, size: 14, color: Color(0xFF22242A))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableFilterTile extends StatelessWidget {
  const _ExpandableFilterTile({
    required this.title,
    required this.expanded,
    required this.onChanged,
  });

  final String title;
  final bool expanded;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!expanded),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              turns: expanded ? 0.5 : 0,
              child: const Icon(
                Icons.expand_more,
                size: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedExpand extends StatelessWidget {
  const _AnimatedExpand({
    required this.expanded,
    required this.child,
  });

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        heightFactor: expanded ? 1 : 0,
        child: child,
      ),
    );
  }
}

class _RingRangeSliderThumbShape extends RangeSliderThumbShape {
  const _RingRangeSliderThumbShape({
    required this.ringColor,
    required this.fillColor,
  });

  final Color ringColor;
  final Color fillColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.square(22);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool isPressed = false,
  }) {
    final canvas = context.canvas;
    final ringPaint = Paint()..color = ringColor;
    final fillPaint = Paint()..color = fillColor;
    canvas.drawCircle(center, 11, ringPaint);
    canvas.drawCircle(center, 9, fillPaint);
  }
}
