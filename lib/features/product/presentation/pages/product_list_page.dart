import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/product/controllers/product_list_controller.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/features/product/models/paginated_products_state.dart';
import 'package:george_pick_mate/features/product/models/product_category_tree_dto.dart';
import 'package:george_pick_mate/features/product/models/product_item.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_filter_panel.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_grid_section.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_list_sort_header.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_sku_cart_side_sheet_widget.dart';
import 'package:george_pick_mate/features/product/services/product_services.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/dismiss_keyboard_on_tap_widget.dart';
import 'package:george_pick_mate/shared/widgets/home_main_content_slot_widget.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({
    this.onSortChanged,
    this.onCategoryChanged,
    this.onSubCategoryChanged,
    super.key,
  });

  final ValueChanged<String>? onSortChanged;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onSubCategoryChanged;

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  static const Duration _sidebarAnimationDuration = Duration(milliseconds: 260);
  final ScrollController _scrollController = ScrollController();
  late final ProviderSubscription<AsyncValue<PaginatedProductsState>>
  _productsSubscription;
  final ProductListController _controller = ProductListController();
  bool _ensureLoadScheduled = false;
  bool _useCollapsedGridColumns = false;
  int _sidebarLayoutSwitchToken = 0;
  final Map<int, bool> _collectOverrides = <int, bool>{};
  final Set<int> _collectSubmitting = <int>{};
  final Set<int> _addToCartSubmitting = <int>{};
  int _addToCartFlowEpoch = 0;
  final TextEditingController _searchKeywordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _useCollapsedGridColumns = _controller.isFilterCollapsed;
    _productsSubscription = ref
        .listenManual<AsyncValue<PaginatedProductsState>>(productsProvider, (
          _,
          next,
        ) {
          if (next is AsyncData<PaginatedProductsState>) {
            _ensureScrollableAndLoadMoreIfNeeded();
          }
        });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 300) {
      ref.read(productsProvider.notifier).loadMoreOnScroll();
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
        ref.read(productsProvider.notifier).loadMoreWhenViewportNotFilled();
      }
    });
  }

  @override
  void dispose() {
    _addToCartFlowEpoch++;
    _addToCartSubmitting.clear();
    _sidebarLayoutSwitchToken++;
    _productsSubscription.close();
    _searchKeywordController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// 用户进行其它列表操作时中断进行中的加购（详情请求 / 即将弹出的侧栏）。
  void _cancelInFlightAddToCartFlow() {
    _addToCartFlowEpoch++;
    if (_addToCartSubmitting.isEmpty) return;
    if (mounted) {
      setState(() => _addToCartSubmitting.clear());
    } else {
      _addToCartSubmitting.clear();
    }
  }

  Future<void> _onProductGridRefresh() async {
    _cancelInFlightAddToCartFlow();
    await ref.read(productsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final categoryTreeState = ref.watch(categoryTreeProvider);
    final isTabletUp = context.isTabletUp;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final columns = isTabletUp
        ? (isLandscape
              ? (_useCollapsedGridColumns ? 5 : 4)
              : (_useCollapsedGridColumns ? 4 : 3))
        : 2;

    return HomeMainContentSlot(
      child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 34 : 0,
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ProductFilterPanel(
                                categoryTree: categoryTreeState,
                                onCategoryTreeRetry: () =>
                                    ref.refresh(categoryTreeProvider),
                                selectedCategoryId:
                                    _controller.selectedCategoryId,
                                onCategoryTap: _onCategoryTap,
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
                      inShowroomSelected: _controller.inShowroomOnly,
                      onInShowroomChanged: _onInShowroomChanged,
                      searchKeywordController: _searchKeywordController,
                      onSearchPressed: _onSearchKeywordSubmitted,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ProductGridSection(
                        productsState: productsState,
                        columns: columns,
                        scrollController: _scrollController,
                        collectOverrides: _collectOverrides,
                        collectSubmitting: _collectSubmitting,
                        addToCartSubmitting: _addToCartSubmitting,
                        onCollectTap: _onCollectTapped,
                        onAddToCartTap: _onAddToCartTapped,
                        onBeforeNavigateToDetail: _cancelInFlightAddToCartFlow,
                        onRetry: _onProductGridRefresh,
                        onRefresh: _onProductGridRefresh,
                        onEnsureLoadMore: _ensureScrollableAndLoadMoreIfNeeded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
    );
  }

  void _onSortChanged(int value) {
    _cancelInFlightAddToCartFlow();
    setState(() => _controller.setSortValue(value));
    widget.onSortChanged?.call(_controller.currentSortOption.text);
    final query = _controller.currentSortQuery;
    ref
        .read(productsProvider.notifier)
        .applySort(sort: query.sort, orderBy: query.orderBy);
  }

  void _onInShowroomChanged(bool selected) {
    _cancelInFlightAddToCartFlow();
    setState(() => _controller.setInShowroomOnly(selected));
    ref
        .read(productsProvider.notifier)
        .applyShowroomSampleFilter(selected);
  }

  void _onSearchKeywordSubmitted() {
    _cancelInFlightAddToCartFlow();
    final keyword = _searchKeywordController.text.trim();
    ref.read(productsProvider.notifier).applyKeywordSearch(keyword);
  }

  /// 点击收藏。
  Future<void> _onCollectTapped(ProductItem product) async {
    _cancelInFlightAddToCartFlow();
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
        ref.invalidate(favoriteProductsProvider);
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

    setState(() => _collectSubmitting.remove(productId));
  }

  Future<void> _onAddToCartTapped(ProductItem product) async {
    final productId = product.id;

    final session = ref.read(sessionControllerProvider).asData?.value;
    if (session?.isAuthenticated != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.cartAddRequireLogin)));
      context.go(AppRoutes.login);
      return;
    }

    _cancelInFlightAddToCartFlow();
    final epoch = _addToCartFlowEpoch;
    setState(() => _addToCartSubmitting.add(productId));
    try {
      final detail = await ref.read(productDetailProvider(productId).future);
      if (!mounted) {
        _addToCartSubmitting.remove(productId);
        return;
      }
      if (epoch != _addToCartFlowEpoch) {
        setState(() => _addToCartSubmitting.remove(productId));
        return;
      }
      setState(() => _addToCartSubmitting.remove(productId));

      final added = await presentProductSkuCartSideSheet(
        context: context,
        detail: detail,
        showMainImage: true,
        mode: ProductSkuCartSheetMode.addToCart,
        onSubmit: (sheetContext, payload) async {
          final space = await resolveSpaceForCartAdd(sheetContext);
          if (space == null) return false;
          return ref
              .read(cartControllerProvider.notifier)
              .createCartItem(
                productId: payload.apiProductId,
                subIndex: payload.subIndex,
                sIndex: payload.sIndex,
                productNum: payload.productNum,
                space: space,
                subName: payload.subName,
              );
        },
      );
      if (!mounted) return;
      if (epoch != _addToCartFlowEpoch) return;
      if (added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.productAddedToCart(product.name)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _addToCartSubmitting.remove(productId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.productDetailLoadFailed('$e'))),
        );
      } else {
        _addToCartSubmitting.remove(productId);
      }
    }
  }

  void _onCategoryTap(ProductCategoryTreeDto category) {
    setState(() => _controller.toggleCategory(category));
    _queryBySelectedCategory();
  }

  void _onCollapseSidebar() {
    _setSidebarCollapsed(true);
  }

  void _onToggleSidebar() {
    _setSidebarCollapsed(!_controller.isFilterCollapsed);
  }

  void _setSidebarCollapsed(bool collapsed) {
    if (_controller.isFilterCollapsed == collapsed &&
        _useCollapsedGridColumns == collapsed) {
      return;
    }

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
      if (!mounted ||
          token != _sidebarLayoutSwitchToken ||
          !_controller.isFilterCollapsed) {
        return;
      }
      setState(() => _useCollapsedGridColumns = true);
    });
  }

  Future<void> _openMobileFilterSheet() async {
    var selectedCategoryId = _controller.selectedCategoryId;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final categoryTreeState = ref.watch(categoryTreeProvider);
          return StatefulBuilder(
            builder: (context, setModalState) => DismissKeyboardOnTap(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: ProductFilterPanel(
                    categoryTree: categoryTreeState,
                    onCategoryTreeRetry: () =>
                        ref.refresh(categoryTreeProvider),
                    selectedCategoryId: selectedCategoryId,
                    onCategoryTap: (category) {
                      _controller.toggleCategory(category);
                      selectedCategoryId = _controller.selectedCategoryId;
                      _queryBySelectedCategory();
                      setState(() {});
                      setModalState(() {});
                      Navigator.of(sheetContext).pop();
                    },
                    onCollapseTap: null,
                    pinApplyButtonToBottom: false,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _queryBySelectedCategory() {
    _cancelInFlightAddToCartFlow();
    final query = _controller.currentSortQuery;
    ref
        .read(productsProvider.notifier)
        .applyCategoryFilter(
          _controller.selectedCategoryId,
          sort: query.sort,
          orderBy: query.orderBy,
        );
    widget.onCategoryChanged?.call(_controller.selectedCategoryLabel);
    widget.onSubCategoryChanged?.call('');
  }
}
