import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/product/controllers/product_list_controller.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/paginated_products_state.dart';
import 'package:groe_app_pad/features/product/models/product_category_tree_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
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
  static const Duration _sidebarAnimationDuration = Duration(milliseconds: 260);
  final ScrollController _scrollController = ScrollController();
  late final ProviderSubscription<AsyncValue<PaginatedProductsState>> _productsSubscription;
  final ProductListController _controller = ProductListController();
  bool _ensureLoadScheduled = false;
  bool _useCollapsedGridColumns = false;
  int _sidebarLayoutSwitchToken = 0;
  final Map<int, bool> _collectOverrides = <int, bool>{};
  final Set<int> _collectSubmitting = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _useCollapsedGridColumns = _controller.isFilterCollapsed;
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
    _sidebarLayoutSwitchToken++;
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
            ? (_useCollapsedGridColumns ? 5 : 4)
            : (_useCollapsedGridColumns ? 4 : 3))
        : 2;

    return Stack(
          children: [
            Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 52 : 10,
            vertical: 30,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isTabletUp)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  width: _controller.isFilterCollapsed ? 0 : 225,
                  child: ClipRect(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _controller.isFilterCollapsed ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: _controller.isFilterCollapsed,
                        child: Row(
                          children: [
                            Expanded(
                              child: ProductFilterPanel(
                                categories:
                                    categoryTreeState.asData?.value ?? const <ProductCategoryTreeDto>[],
                                selectedCategoryId: _controller.selectedCategoryId,
                                onCategoryTap: _onCategoryTap,
                                onApplyTap: _onApplyTap,
                                onCollapseTap: _onCollapseSidebar,
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
                      selectedSortValue: _controller.selectedSortValue,
                      selectedSortLabel: _controller.currentSortOption.text,
                      onSortChanged: _onSortChanged,
                      isSidebarCollapsed: _controller.isFilterCollapsed,
                      onToggleSidebar: isTabletUp ? _onToggleSidebar : null,
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
                        onAddToCartTap: _onAddToCartTapped,
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
    setState(() => _controller.setSortValue(value));
    widget.onSortChanged?.call(_controller.currentSortOption.text);
    final query = _controller.currentSortQuery;
    ref.read(productsProvider.notifier).applyFilters(
          categoryId: _controller.selectedCategoryId,
          sort: query.sort,
          orderBy: query.orderBy,
        );
  }

  void _onApplyTap() {
    _logSearchParams();
    ref.read(productsProvider.notifier).applyFilters(
          categoryId: _controller.selectedCategoryId,
          sort: _controller.currentSortQuery.sort,
          orderBy: _controller.currentSortQuery.orderBy,
        );
    widget.onSortChanged?.call(_controller.currentSortOption.text);
    widget.onCategoryChanged?.call(_controller.selectedCategoryLabel);
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
        ref.read(favoritesRevisionProvider.notifier).bump();
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

  void _onAddToCartTapped(ProductItem product) {
    ref.read(cartControllerProvider.notifier).addProduct(product);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.productAddedToCart(product.name))),
    );
  }

  void _onCategoryTap(ProductCategoryTreeDto category) {
    setState(() => _controller.toggleCategory(category));
  }

  void _onCollapseSidebar() {
    _setSidebarCollapsed(true);
  }

  void _onToggleSidebar() {
    _setSidebarCollapsed(!_controller.isFilterCollapsed);
  }

  void _setSidebarCollapsed(bool collapsed) {
    if (_controller.isFilterCollapsed == collapsed && _useCollapsedGridColumns == collapsed) return;

    if (!collapsed) {
      setState(() {
        _sidebarLayoutSwitchToken++;
        _controller.isFilterCollapsed = false;
        _useCollapsedGridColumns = false;
      });
      return;
    }

    setState(() {
      _sidebarLayoutSwitchToken++;
      _controller.isFilterCollapsed = true;
      // 收起动画进行中时，先保留展开态列数，避免卡片区域瞬时变窄导致溢出。
      _useCollapsedGridColumns = false;
    });

    final token = _sidebarLayoutSwitchToken;
    Future<void>.delayed(_sidebarAnimationDuration, () {
      if (!mounted || token != _sidebarLayoutSwitchToken || !_controller.isFilterCollapsed) return;
      setState(() => _useCollapsedGridColumns = true);
    });
  }

  void _logSearchParams() {
    debugPrint(_controller.buildSearchLog(trigger: 'apply_filters'));
  }

  Future<void> _openMobileFilterSheet() async {
    final categories = ref.read(categoryTreeProvider).asData?.value ?? const <ProductCategoryTreeDto>[];
    var selectedCategoryId = _controller.selectedCategoryId;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ProductFilterPanel(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              onCategoryTap: (category) {
                _controller.toggleCategory(category);
                selectedCategoryId = _controller.selectedCategoryId;
                setState(() {});
                setModalState(() {});
              },
              onApplyTap: () {
                _onApplyTap();
                Navigator.of(context).pop();
              },
              onCollapseTap: null,
              pinApplyButtonToBottom: false,
            ),
          ),
        ),
      ),
    );
  }
}
