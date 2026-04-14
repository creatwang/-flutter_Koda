import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/paginated_products_state.dart';
import 'package:groe_app_pad/features/product/models/product_category_tree_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/presentation/pages/qr_scan_page.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_card.dart';
import 'package:groe_app_pad/features/product/services/product_services.dart';
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

class _SortOption {
  const _SortOption({
    required this.text,
    required this.value,
  });

  final String text;
  final int value;
}

class _SortQuery {
  const _SortQuery({
    required this.sort,
    required this.orderBy,
  });

  final String? sort;
  final int orderBy;
}

const List<_SortOption> _sortByOpts = <_SortOption>[
  _SortOption(text: 'Default', value: 0),
  _SortOption(text: 'Price(Low > High)', value: 1),
  _SortOption(text: 'Price(Low < High)', value: 2),
  _SortOption(text: 'Rating(Highest)', value: 3),
  _SortOption(text: 'Rating(Lowest)', value: 4),
  _SortOption(text: 'Model(A - Z)', value: 5),
  _SortOption(text: 'Model(Z - A)', value: 6),
];

const Map<int, _SortQuery> _mapSortBy = <int, _SortQuery>{
  0: _SortQuery(sort: null, orderBy: 0),
  1: _SortQuery(sort: 'asc', orderBy: 1),
  2: _SortQuery(sort: 'desc', orderBy: 1),
  3: _SortQuery(sort: 'desc', orderBy: 2),
  4: _SortQuery(sort: 'asc', orderBy: 2),
  5: _SortQuery(sort: 'asc', orderBy: 3),
  6: _SortQuery(sort: 'desc', orderBy: 3),
};

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();
  late final ProviderSubscription<AsyncValue<PaginatedProductsState>> _productsSubscription;
  bool _ensureLoadScheduled = false;
  RangeValues _priceRange = const RangeValues(0, 50000);
  final Set<String> _selectedBrands = <String>{'B&B Italia'};
  int? _selectedCategoryId;
  String _selectedCategoryLabel = '';
  int _selectedSortValue = 0;
  bool _lightingExpanded = false;
  bool _artExpanded = false;
  bool _isFilterCollapsed = false;
  final Map<int, bool> _collectOverrides = <int, bool>{};
  final Set<int> _collectSubmitting = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _productsSubscription = ref.listenManual<AsyncValue<PaginatedProductsState>>(
      productsProvider,
      (_, next) {
        if (next is AsyncData<PaginatedProductsState>) {
          _ensureScrollableAndLoadMoreIfNeeded();
        }
      },
    );
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
    _productsSubscription.close();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final productsState = ref.watch(productsProvider);
    final categoryTreeState = ref.watch(categoryTreeProvider);
    final isTabletUp = context.isTabletUp;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final columns = isTabletUp
        ? (isLandscape
            ? (_isFilterCollapsed ? 5 : 4)
            : (_isFilterCollapsed ? 4 : 3))
        : 2;

    return Stack(
          children: [
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isTabletUp)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  width: _isFilterCollapsed ? 0 : 225,
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
                                categories:
                                    categoryTreeState.asData?.value ?? const <ProductCategoryTreeDto>[],
                                selectedCategoryId: _selectedCategoryId,
                                selectedBrands: _selectedBrands,
                                priceRange: _priceRange,
                                lightingExpanded: _lightingExpanded,
                                artExpanded: _artExpanded,
                                onCategoryTap: _onCategoryTap,
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
                      selectedSortValue: _selectedSortValue,
                      selectedSortLabel: _currentSortOption.text,
                      onSortChanged: _onSortChanged,
                      isSidebarCollapsed: _isFilterCollapsed,
                      onToggleSidebar: isTabletUp
                          ? () => setState(() => _isFilterCollapsed = !_isFilterCollapsed)
                          : null,
                      onOpenFilters: isTabletUp ? null : _openMobileFilterSheet,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: productsState.when(
                        loading: () => const AppLoadingView(),
                        error: (error, _) => AppErrorView(
                          message: l10n.productLoadFailed(error.toString()),
                          onRetry: () => ref.read(productsProvider.notifier).refresh(),
                        ),
                        data: (items) {
                          return RefreshIndicator(
                            onRefresh: () => ref.read(productsProvider.notifier).refresh(),
                            child: items.items.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 60),
                                    children: [
                                      AppEmptyView(message: l10n.productEmpty),
                                    ],
                                  )
                                : Builder(
                                    builder: (_) {
                                      return GridView.builder(
                                        controller: _scrollController,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        padding:
                                            const EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 8),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: columns,
                                          crossAxisSpacing: 14,
                                          mainAxisSpacing: 14,
                                          childAspectRatio: 0.76,
                                        ),
                                        itemCount: items.items.length + (items.isLoadingMore ? 1 : 0),
                                        itemBuilder: (_, index) {
                                          if (index >= items.items.length) {
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                          final product = items.items[index];
                                          final isCollected =
                                              _collectOverrides[product.id] ?? product.isCollect;
                                          return ProductCard(
                                            productItem: product,
                                            isCollected: isCollected,
                                            isCollectSubmitting: _collectSubmitting.contains(product.id),
                                            onCollectTap: () => _onCollectTapped(product),
                                          );
                                        },
                                      );
                                    },
                                  ),
                            /* child: Stack(
                          children: [
                            MasonryGridView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 24),
                              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                              ),
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              itemCount: items.items.length,
                              itemBuilder: (_, index) {
                                final product = items.items[index];
                                return ProductCard(
                                  productItem: product,
                                  isCollected: _collectOverrides[product.id] ?? product.isCollect,
                                  onCollectChanged: (isCollected) =>
                                      _onCollectChanged(product.id, isCollected),
                                );
                              },
                            ),
                            if (items.isLoadingMore)
                              const Positioned(
                                left: 0,
                                right: 0,
                                bottom: 6,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        ),*/
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
            Positioned.fill(
              child: _DraggableScanFab(
                tooltip: context.l10n.productScanTooltip,
                onTap: _onScanQrTap,
              ),
            ),
          ],
    );
  }

  _SortOption get _currentSortOption {
    return _sortByOpts.firstWhere(
      (e) => e.value == _selectedSortValue,
      orElse: () => _sortByOpts.first,
    );
  }

  _SortQuery get _currentSortQuery => _mapSortBy[_selectedSortValue] ?? const _SortQuery(sort: null, orderBy: 0);

  void _onSortChanged(int value) {
    final option = _sortByOpts.firstWhere(
      (e) => e.value == value,
      orElse: () => _sortByOpts.first,
    );
    setState(() => _selectedSortValue = option.value);
    widget.onSortChanged?.call(option.text);
    final query = _mapSortBy[option.value] ?? const _SortQuery(sort: null, orderBy: 0);
    ref.read(productsProvider.notifier).applyFilters(
          categoryId: _selectedCategoryId,
          sort: query.sort,
          orderBy: query.orderBy,
        );
  }

  void _onApplyTap() {
    _logSearchParams(trigger: 'apply_filters');
    ref.read(productsProvider.notifier).applyFilters(
          categoryId: _selectedCategoryId,
          sort: _currentSortQuery.sort,
          orderBy: _currentSortQuery.orderBy,
        );
    widget.onSortChanged?.call(_currentSortOption.text);
    widget.onCategoryChanged?.call(_selectedCategoryLabel);
    widget.onSubCategoryChanged?.call('');
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

  Future<void> _onScanQrTap() async {
    final session = ref.read(sessionControllerProvider).asData?.value;
    if (session?.isAuthenticated != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productScanRequireLogin)),
      );
      context.go(AppRoutes.login);
      return;
    }

    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const QrScanPage(),
      ),
    );
    if (!mounted || code == null || code.trim().isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.productScanResult(code))),
    );
  }
  
  /// 点击收藏。
  Future<void> _onCollectTapped(ProductItem product) async {
    final productId = product.id;
    if (_collectSubmitting.contains(productId)) return;
    final hasOverride = _collectOverrides.containsKey(productId);
    final previous = _collectOverrides[productId];
    final current = _collectOverrides[productId] ?? product.isCollect;
    final target = !current;

    setState(() {
      _collectSubmitting.add(productId);
      _collectOverrides[productId] = target;
    });

    final result = target
        ? await createFavorService(productId: productId)
        : await deleteFavorService(productId: productId);

    if (!mounted) return;

    result.when(
      success: (_) {
        debugPrint(
          '[product_list] trigger=collect_changed, productId=$productId, isCollect=$target',
        );
      },
      failure: (exception) {
        setState(() {
          if (hasOverride && previous != null) {
            _collectOverrides[productId] = previous;
          } else {
            _collectOverrides.remove(productId);
          }
        });
        debugPrint(
          '[product_list] trigger=collect_changed_failed, productId=$productId, '
          'isCollect=$target, error=${exception.message}',
        );
      },
    );

    if (!mounted) return;
    setState(() => _collectSubmitting.remove(productId));
  }

  void _onCategoryTap(ProductCategoryTreeDto category) {
    final id = category.id;
    if (id == null) return;
    final isSameCategory = _selectedCategoryId == id;
    final nextCategoryId = isSameCategory ? null : id;
    final nextCategoryLabel = isSameCategory ? '' : (category.name ?? '');

    setState(() {
      _selectedCategoryId = nextCategoryId;
      _selectedCategoryLabel = nextCategoryLabel;
    });
  }

  void _logSearchParams({required String trigger}) {
    debugPrint(
      '[product_list] trigger=$trigger, sortValue=$_selectedSortValue, '
      'sort=${_currentSortQuery.sort ?? 'null'}, order_by=${_currentSortQuery.orderBy}, '
      'shopCateGoryId=${_selectedCategoryId ?? 0}, '
      'categoryLabel=${_selectedCategoryLabel.isEmpty ? 'none' : _selectedCategoryLabel}, '
      'priceStart=${_priceRange.start.toStringAsFixed(0)}, '
      'priceEnd=${_priceRange.end.toStringAsFixed(0)}, '
      'brands=${_selectedBrands.join('|')}',
    );
  }

  Future<void> _openMobileFilterSheet() async {
    final categories = ref.read(categoryTreeProvider).asData?.value ?? const <ProductCategoryTreeDto>[];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: _FilterPanel(
            categories: categories,
            selectedCategoryId: _selectedCategoryId,
            selectedBrands: _selectedBrands,
            priceRange: _priceRange,
            lightingExpanded: _lightingExpanded,
            artExpanded: _artExpanded,
            onCategoryTap: _onCategoryTap,
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

class _DraggableScanFab extends StatefulWidget {
  const _DraggableScanFab({
    required this.tooltip,
    required this.onTap,
  });

  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_DraggableScanFab> createState() => _DraggableScanFabState();
}

class _DraggableScanFabState extends State<_DraggableScanFab> {
  static const double _fabSize = 56;
  static const double _fabMargin = 20;

  Offset? _fabOffset;
  bool _fabDragging = false;

  Offset _defaultFabOffset(Size size) {
    final maxX = _maxFabX(size);
    final maxY = _maxFabY(size);
    return Offset(maxX, maxY);
  }

  double _maxFabX(Size size) {
    final maxX = size.width - _fabSize - _fabMargin;
    return maxX < _fabMargin ? _fabMargin : maxX;
  }

  double _maxFabY(Size size) {
    final maxY = size.height - _fabSize - _fabMargin;
    return maxY < _fabMargin ? _fabMargin : maxY;
  }

  Offset _clampFabOffset(Offset value, Size size) {
    return Offset(
      value.dx.clamp(_fabMargin, _maxFabX(size)),
      value.dy.clamp(_fabMargin, _maxFabY(size)),
    );
  }

  void _onFabDragUpdate(DragUpdateDetails details, Size canvasSize) {
    final current = _fabOffset ?? _defaultFabOffset(canvasSize);
    setState(() {
      _fabDragging = true;
      _fabOffset = _clampFabOffset(current + details.delta, canvasSize);
    });
  }

  void _onFabDragEnd(Size canvasSize) {
    final current = _clampFabOffset(_fabOffset ?? _defaultFabOffset(canvasSize), canvasSize);
    final dockLeft = current.dx + (_fabSize / 2) < (canvasSize.width / 2);
    final targetX = dockLeft ? _fabMargin : _maxFabX(canvasSize);
    setState(() {
      _fabDragging = false;
      _fabOffset = Offset(targetX, current.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final fabOffset = _clampFabOffset(_fabOffset ?? _defaultFabOffset(canvasSize), canvasSize);
        return Stack(
          children: [
            AnimatedPositioned(
              duration: _fabDragging ? Duration.zero : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              left: fabOffset.dx,
              top: fabOffset.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) => _onFabDragUpdate(details, canvasSize),
                onPanEnd: (_) => _onFabDragEnd(canvasSize),
                child: Tooltip(
                  message: widget.tooltip,
                  child: FloatingActionButton(
                    heroTag: 'product_scan_qr_fab',
                    onPressed: widget.onTap,
                    child: const Icon(Icons.qr_code_scanner_rounded),
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

class _SortHeader extends StatelessWidget {
  const _SortHeader({
    required this.selectedSortValue,
    required this.selectedSortLabel,
    required this.onSortChanged,
    required this.isSidebarCollapsed,
    this.onToggleSidebar,
    this.onOpenFilters,
  });

  final int selectedSortValue;
  final String selectedSortLabel;
  final ValueChanged<int> onSortChanged;
  final bool isSidebarCollapsed;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onOpenFilters;

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
                        fontSize: 24
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
          child: SizedBox(
            height: 40,
            child: PopupMenuButton<int>(
              tooltip: '',
              padding: EdgeInsets.zero,
              initialValue: selectedSortValue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: const Color(0xFF2B2F34),
              constraints: const BoxConstraints(minWidth: 220),
              onSelected: onSortChanged,
              itemBuilder: (context) => _sortByOpts
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Sort by: $selectedSortLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more, size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedBrands,
    required this.priceRange,
    required this.lightingExpanded,
    required this.artExpanded,
    required this.onCategoryTap,
    required this.onPriceChanged,
    required this.onBrandToggle,
    required this.onApplyTap,
    required this.onCollapseTap,
    required this.onLightingExpandedChanged,
    required this.onArtExpandedChanged,
    required this.pinApplyButtonToBottom,
  });

  final List<ProductCategoryTreeDto> categories;
  final int? selectedCategoryId;
  final Set<String> selectedBrands;
  final RangeValues priceRange;
  final bool lightingExpanded;
  final bool artExpanded;
  final ValueChanged<ProductCategoryTreeDto> onCategoryTap;
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
      children: categories.isEmpty
          ? [
              Text(
                'No categories',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ]
          : categories
              .map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CategoryTreeNode(
                    category: category,
                    selectedCategoryId: selectedCategoryId,
                    onCategoryTap: onCategoryTap,
                  ),
                ),
              )
              .toList(growable: false),
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
                      fontSize: 16
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
/*        const SizedBox(height: 14),
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFE3AE2B),
            inactiveTrackColor: const Color(0xFFDCE4F1).withValues(alpha: 0.92),
            overlayColor: const Color(0x30E3AE2B),
            trackHeight: 3,
            overlayShape: SliderComponentShape.noOverlay,
            rangeTrackShape: const _FullWidthRangeSliderTrackShape(),
            rangeThumbShape: const _RingRangeSliderThumbShape(
              ringColor: Color(0xFF003F7F),
              fillColor: Color(0xFFECECEC),
              outerRadius: 8,
              innerRadius: 6,
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('¥0', style: TextStyle(color: Colors.white.withValues(alpha: 0.86), fontSize: 10)),
            Text(
              '¥${_formatYuan(priceRange.end)}+',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.86), fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Brand Curation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
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
        ),*/
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
                    child: const Text('Apply Filters', style: TextStyle(
                      fontSize: 14
                    ),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _CategoryTreeNode extends StatefulWidget {
  const _CategoryTreeNode({
    required this.category,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  final ProductCategoryTreeDto category;
  final int? selectedCategoryId;
  final ValueChanged<ProductCategoryTreeDto> onCategoryTap;

  @override
  State<_CategoryTreeNode> createState() => _CategoryTreeNodeState();
}

class _CategoryTreeNodeState extends State<_CategoryTreeNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final categoryId = widget.category.id;
    final categoryName = widget.category.name ?? '';
    final children = widget.category.children;
    final hasChildren = children.isNotEmpty;
    final selected = categoryId != null && widget.selectedCategoryId == categoryId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? Colors.white.withValues(alpha: 0.26)
                : Colors.white.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: categoryId == null ? null : () => widget.onCategoryTap(widget.category),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (hasChildren)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasChildren) ...[
          _AnimatedExpand(
            expanded: _expanded,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _CategoryTreeNode(
                          category: child,
                          selectedCategoryId: widget.selectedCategoryId,
                          onCategoryTap: widget.onCategoryTap,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ],
      ],
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
