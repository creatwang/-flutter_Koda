import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/paginated_products_state.dart';
import 'package:groe_app_pad/features/product/models/product_category_tree_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/presentation/controllers/product_list_view_model.dart';
import 'package:groe_app_pad/features/product/presentation/pages/qr_scan_page.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/draggable_scan_fab.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_filter_panel.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_grid_section.dart';
import 'package:groe_app_pad/features/product/presentation/widgets/product_list_sort_header.dart';
import 'package:groe_app_pad/features/product/services/product_services.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({
    this.onSortChanged,
    this.onApplyFilters,
    this.onCategoryChanged,
    this.onSubCategoryChanged,
    super.key,
  });

  final ValueChanged<String>? onSortChanged;
  final VoidCallback? onApplyFilters;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onSubCategoryChanged;

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();
  late final ProviderSubscription<AsyncValue<PaginatedProductsState>> _productsSubscription;
  final ProductListViewModel _viewModel = ProductListViewModel();
  bool _ensureLoadScheduled = false;
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
    final productsState = ref.watch(productsProvider);
    final categoryTreeState = ref.watch(categoryTreeProvider);
    final isTabletUp = context.isTabletUp;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final columns = isTabletUp
        ? (isLandscape
            ? (_viewModel.isFilterCollapsed ? 5 : 4)
            : (_viewModel.isFilterCollapsed ? 4 : 3))
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
                  width: _viewModel.isFilterCollapsed ? 0 : 225,
                  child: ClipRect(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _viewModel.isFilterCollapsed ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: _viewModel.isFilterCollapsed,
                        child: Row(
                          children: [
                            Expanded(
                              child: ProductFilterPanel(
                                categories:
                                    categoryTreeState.asData?.value ?? const <ProductCategoryTreeDto>[],
                                selectedCategoryId: _viewModel.selectedCategoryId,
                                onCategoryTap: _onCategoryTap,
                                onApplyTap: _onApplyTap,
                                onCollapseTap: () => setState(_viewModel.collapseSidebar),
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
                    ProductSortHeader(
                      selectedSortValue: _viewModel.selectedSortValue,
                      selectedSortLabel: _viewModel.currentSortOption.text,
                      onSortChanged: _onSortChanged,
                      isSidebarCollapsed: _viewModel.isFilterCollapsed,
                      onToggleSidebar: isTabletUp
                          ? () => setState(_viewModel.toggleSidebar)
                          : null,
                      onOpenFilters: isTabletUp ? null : _openMobileFilterSheet,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ProductGridSection(
                        productsState: productsState,
                        columns: columns,
                        scrollController: _scrollController,
                        collectOverrides: _collectOverrides,
                        collectSubmitting: _collectSubmitting,
                        onCollectTap: _onCollectTapped,
                        onRetry: () => ref.read(productsProvider.notifier).refresh(),
                        onRefresh: () => ref.read(productsProvider.notifier).refresh(),
                        onEnsureLoadMore: _ensureScrollableAndLoadMoreIfNeeded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
            Positioned.fill(
              child: DraggableScanFab(
                tooltip: context.l10n.productScanTooltip,
                onTap: _onScanQrTap,
              ),
            ),
          ],
    );
  }

  void _onSortChanged(int value) {
    setState(() => _viewModel.setSortValue(value));
    widget.onSortChanged?.call(_viewModel.currentSortOption.text);
    final query = _viewModel.currentSortQuery;
    ref.read(productsProvider.notifier).applyFilters(
          categoryId: _viewModel.selectedCategoryId,
          sort: query.sort,
          orderBy: query.orderBy,
        );
  }

  void _onApplyTap() {
    _logSearchParams();
    ref.read(productsProvider.notifier).applyFilters(
          categoryId: _viewModel.selectedCategoryId,
          sort: _viewModel.currentSortQuery.sort,
          orderBy: _viewModel.currentSortQuery.orderBy,
        );
    widget.onSortChanged?.call(_viewModel.currentSortOption.text);
    widget.onCategoryChanged?.call(_viewModel.selectedCategoryLabel);
    widget.onSubCategoryChanged?.call('');
    widget.onApplyFilters?.call();
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
    setState(() => _viewModel.toggleCategory(category));
  }

  void _logSearchParams() {
    debugPrint(_viewModel.buildSearchLog(trigger: 'apply_filters'));
  }

  Future<void> _openMobileFilterSheet() async {
    final categories = ref.read(categoryTreeProvider).asData?.value ?? const <ProductCategoryTreeDto>[];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ProductFilterPanel(
            categories: categories,
            selectedCategoryId: _viewModel.selectedCategoryId,
            onCategoryTap: _onCategoryTap,
            onApplyTap: _onApplyTap,
            onCollapseTap: null,
            pinApplyButtonToBottom: false,
          ),
        ),
      ),
    );
  }
}
