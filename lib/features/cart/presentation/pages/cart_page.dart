import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/cart/presentation/cart_clear_all_confirm_flow.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_mall_confirm_dialog.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/services/cart_services.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_sku_cart_side_sheet_widget.dart';
import 'package:intl/intl.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/home_main_content_slot_widget.dart';
import 'package:george_pick_mate/shared/widgets/app_empty_view.dart';
import 'package:george_pick_mate/shared/widgets/app_error_view.dart';
import 'package:george_pick_mate/shared/widgets/app_loading_view.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/mall_outlined_cta_button_widget.dart';
import 'package:george_pick_mate/shared/base_widget/small_check_square_checkbox_widget.dart';
import 'package:george_pick_mate/theme/pro_max_tokens.dart';

import '../../models/cart_list_dto.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final Set<String> _collapsedSpaceKeys = <String>{};
  final Set<int> _pendingItemIds = <int>{};
  final Set<int> _removeActionLoadingItemIds = <int>{};
  final Set<int> _changeSpecLoadingItemIds = <int>{};
  final Set<int> _pendingSiteIds = <int>{};
  bool _isClearingAll = false;
  bool _isPreSubmitting = false;

  /// 各站点当前选择的 SM id（与 [_CartSiteSection] 内选择器同步）。
  final Map<int, int> _reportedSmIdByCompanyId = <int, int>{};
  final NumberFormat _amountFormatter = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cartState = ref.watch(cartControllerProvider);
    final totalCount = ref.watch(cartListBadgeCountProvider);
    final selectedCount = ref.watch(cartSelectedCountProvider);
    final selectedAmount = ref.watch(cartSelectedAmountProvider);
    return cartState.when(
      loading: () => const HomeMainContentSlot(child: AppLoadingView()),
      error: (error, _) => HomeMainContentSlot(
        child: AppErrorView(message: l10n.cartLoadFailed(error.toString())),
      ),
      data: (groups) {
        final siteCount = groups.fold<int>(0, (n, g) => n + g.items.length);
        if (siteCount == 0) {
          return HomeMainContentSlot(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppEmptyView(message: l10n.cartEmpty),
                SizedBox(height: 10),
                MallOutlinedCtaButtonWidget(
                  width: 200,
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.38)),
                  onPressed: () {
                    ref.invalidate(preOrderCartControllerProvider);
                    context.push(AppRoutes.preOrder);
                  },
                  child: const Text('Go To Pre Order'),
                ),
              ],
            ),
          );
        }

        final isWide = MediaQuery.sizeOf(context).width >= 1120;
        final listPanel = _buildCuratedListPanel(context, groups);
        final summaryPanel = _buildSummaryPanel(
          context,
          groups: groups,
          selectedCount: selectedCount,
          selectedAmount: selectedAmount,
          totalCount: totalCount,
        );

        return HomeMainContentSlot(
          child: isWide
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: listPanel),
                        const SizedBox(width: 18),
                        SizedBox(
                          width: 330,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight,
                            ),
                            child: LayoutBuilder(
                              builder: (context, viewport) {
                                return SingleChildScrollView(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: viewport.maxHeight,
                                    ),
                                    child: summaryPanel,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Column(
                  children: [
                    Expanded(flex: 5, child: listPanel),
                    Expanded(
                      flex: 2,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                          child: LayoutBuilder(
                            builder: (context, viewport) {
                              return SingleChildScrollView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: viewport.maxHeight,
                                  ),
                                  child: summaryPanel,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCuratedListPanel(
    BuildContext context,
    List<CartListDto> groups,
  ) {
    final siteEntries = <({CartListDto group, CartSiteDto site})>[
      for (final g in groups)
        for (final s in g.items) (group: g, site: s),
    ];
    return RefreshIndicator(
      onRefresh: () => ref.read(cartControllerProvider.notifier).refresh(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Curated Shortlist',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: ProMaxTokens.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${siteEntries.length} EXCLUSIVE SECTIONS SELECTED',
              style: TextStyle(
                color: ProMaxTokens.textSecondary.withValues(alpha: 0.85),
                letterSpacing: 1.1,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: siteEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, index) {
                  final e = siteEntries[index];
                  final grp = e.group;
                  final s = e.site;
                  final smPickerReps = s.smItems.isNotEmpty
                      ? s.smItems
                      : grp.smItems;
                  final resolvedSmId = s.smId > 0 ? s.smId : grp.smId;
                  return _CartSiteSection(
                    site: s,
                    smPickerReps: smPickerReps,
                    resolvedServerSmId: resolvedSmId,
                    isSpaceExpanded: (space) => _isSpaceExpanded(s, space),
                    onToggleSpaceExpanded: (space) => _toggleSpace(s, space),
                    onToggleSiteSelected: (selected) =>
                        _onToggleSiteSelected(s, selected),
                    onToggleItemSelected: (itemId, selected) =>
                        _onToggleItemSelected(itemId, selected),
                    onChangeQuantity: _onChangeQuantity,
                    onDeleteItem: _onDeleteItem,
                    onRemarkChanged: _onRemarkChanged,
                    onChangeSpec: _onChangeSpec,
                    onSiteSmSelectionReported: _onSiteSmSelectionReported,
                    isSiteBusy: _pendingSiteIds.contains(s.companyId),
                    isItemBusy: (itemId) =>
                        _pendingItemIds.contains(itemId) ||
                        _pendingSiteIds.contains(s.companyId),
                    isRemoveActionLoading: (itemId) =>
                        _removeActionLoadingItemIds.contains(itemId),
                    isChangeSpecLoading: (itemId) =>
                        _changeSpecLoadingItemIds.contains(itemId),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSiteSmSelectionReported(int companyId, int smId) {
    if (_reportedSmIdByCompanyId[companyId] == smId) return;
    setState(() => _reportedSmIdByCompanyId[companyId] = smId);
  }

  Future<void> _onPreSubmitOrder(List<CartListDto> groups) async {
    if (_isPreSubmitting) return;
    final message = validateSmForPreSubmitOrder(
      groups: groups,
      reportedSmIdByCompanyId: _reportedSmIdByCompanyId,
    );
    if (message != null) {
      showGlobalErrorMessage(message);
      return;
    }
    setState(() => _isPreSubmitting = true);
    try {
      final result = await ref
          .read(cartControllerProvider.notifier)
          .submitPreSubmitOrderAfterSmValidation(
            reportedSmIdByCompanyId: _reportedSmIdByCompanyId,
          );
      if (!mounted) return;
      result.when(
        success: (_) {
          ref.invalidate(cartControllerProvider);
          ref.invalidate(preOrderCartControllerProvider);
          context.push(AppRoutes.preOrder);
        },
        failure: (e) => showGlobalErrorMessage(e.message),
      );
    } finally {
      if (mounted) setState(() => _isPreSubmitting = false);
    }
  }

  Widget _buildSummaryPanel(
    BuildContext context, {
    required List<CartListDto> groups,
    required int selectedCount,
    required double selectedAmount,
    required int totalCount,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROJECT SUMMARY',
                style: TextStyle(
                  color: ProMaxTokens.textPrimary.withValues(alpha: 0.95),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _SummaryRow(
                label: 'Total items selected',
                // value: '$selectedCount / $totalCount',
                value: '$selectedCount items',
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withValues(alpha: 1), height: 2),
              const SizedBox(height: 20),
              Text(
                'ESTIMATED TOTAL AMOUNT',
                style: TextStyle(
                  color: ProMaxTokens.textSecondary.withValues(alpha: 0.9),
                  letterSpacing: 0.9,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${_amountFormatter.format(selectedAmount)}',
                style: const TextStyle(
                  color: ProMaxTokens.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selectedCount < 1 || _isPreSubmitting
                      ? null
                      : () => unawaited(_onPreSubmitOrder(groups)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isPreSubmitting) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Text('Pre Submit Order'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              MallOutlinedCtaButtonWidget(
                width: double.infinity,
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.38)),
                isLoading: _isClearingAll,
                onPressed: _onClearAll,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.preOrder),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                ),
                icon: const Icon(Icons.assignment_outlined, size: 16),
                label: const Text('Pre Order'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _spaceKey(CartSiteDto site, CartSpaceDto space) {
    return '${site.companyId}::${space.key}::${space.name}';
  }

  bool _isSpaceExpanded(CartSiteDto site, CartSpaceDto space) {
    return !_collapsedSpaceKeys.contains(_spaceKey(site, space));
  }

  void _toggleSpace(CartSiteDto site, CartSpaceDto space) {
    final key = _spaceKey(site, space);
    setState(() {
      if (_collapsedSpaceKeys.contains(key)) {
        _collapsedSpaceKeys.remove(key);
      } else {
        _collapsedSpaceKeys.add(key);
      }
    });
  }

  Future<void> _onClearAll() async {
    final current =
        ref.read(cartControllerProvider).asData?.value ?? const <CartListDto>[];
    await runCartClearAllConfirmFlow(
      context: context,
      currentGroups: current,
      cartNotifier: ref.read(cartControllerProvider.notifier),
      onBusy: (isBusy) {
        if (mounted) setState(() => _isClearingAll = isBusy);
      },
    );
  }

  Future<bool> _onToggleSiteSelected(CartSiteDto site, bool selected) async {
    final ids = site.cart.items
        .expand((space) => space.list)
        .map((item) => item.id)
        .toList(growable: false);
    if (ids.isEmpty || _pendingSiteIds.contains(site.companyId)) {
      return false;
    }
    setState(() {
      _pendingSiteIds.add(site.companyId);
      _pendingItemIds.addAll(ids);
    });
    final ok = await ref
        .read(cartControllerProvider.notifier)
        .toggleSiteSelected(companyId: site.companyId, selected: selected);
    if (!mounted) return ok;
    setState(() {
      _pendingSiteIds.remove(site.companyId);
      _pendingItemIds.removeAll(ids);
    });
    return ok;
  }

  Future<bool> _onToggleItemSelected(int itemId, bool selected) {
    return _runItemAction(
      itemId,
      () => ref
          .read(cartControllerProvider.notifier)
          .toggleProductSelected(cartId: itemId, selected: selected),
    );
  }

  Future<bool> _onChangeQuantity(CartProductDto item, int nextProductNum) {
    if (nextProductNum < 1) return Future<bool>.value(false);
    return _runItemAction(
      item.id,
      () => ref
          .read(cartControllerProvider.notifier)
          .changeProductQuantity(cartId: item.id, productNum: nextProductNum),
    );
  }

  Future<bool> _onDeleteItem(CartProductDto item) async {
    if (_pendingItemIds.contains(item.id)) return false;
    final confirmed = await _showDeleteItemConfirmDialog(item);
    if (!mounted || !confirmed) return false;
    return _runItemAction(
      item.id,
      () => ref.read(cartControllerProvider.notifier).removeCartItem(item.id),
      removeActionLoading: true,
    );
  }

  Future<void> _onChangeSpec(CartProductDto item) async {
    if (_pendingItemIds.contains(item.id)) return;
    setState(() {
      _pendingItemIds.add(item.id);
      _changeSpecLoadingItemIds.add(item.id);
    });
    try {
      final detail = await ref.read(
        productDetailProvider(item.productId).future,
      );
      if (!mounted) return;
      await presentProductSkuCartSideSheet(
        context: context,
        detail: detail,
        showMainImage: true,
        cartLine: item,
        mode: ProductSkuCartSheetMode.changeSpec,
        onSubmit: (sheetContext, payload) async {
          final space = await resolveSpaceForCartAdd(sheetContext);
          if (space == null) return false;
          return ref
              .read(cartControllerProvider.notifier)
              .changeCartItemSpec(
                cartItemId: item.id,
                productId: payload.apiProductId,
                subIndex: payload.subIndex,
                space: space,
                subName: payload.subName,
              );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productDetailLoadFailed('$e'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _pendingItemIds.remove(item.id);
          _changeSpecLoadingItemIds.remove(item.id);
        });
      } else {
        _pendingItemIds.remove(item.id);
        _changeSpecLoadingItemIds.remove(item.id);
      }
    }
  }

  Future<bool> _runItemAction(
    int itemId,
    Future<bool> Function() action, {
    bool removeActionLoading = false,
  }) async {
    if (_pendingItemIds.contains(itemId)) return false;
    setState(() {
      _pendingItemIds.add(itemId);
      if (removeActionLoading) {
        _removeActionLoadingItemIds.add(itemId);
      }
    });
    try {
      return await action();
    } finally {
      if (mounted) {
        setState(() {
          _pendingItemIds.remove(itemId);
          if (removeActionLoading) {
            _removeActionLoadingItemIds.remove(itemId);
          }
        });
      } else {
        _pendingItemIds.remove(itemId);
        if (removeActionLoading) {
          _removeActionLoadingItemIds.remove(itemId);
        }
      }
    }
  }

  void _onRemarkChanged(int cartId, String remark) {
    unawaited(
      ref
          .read(cartControllerProvider.notifier)
          .updateProductRemark(cartId: cartId, remark: remark),
    );
  }

  Future<bool> _showDeleteItemConfirmDialog(CartProductDto item) async {
    final result = await showMallConfirmDialog(
      context: context,
      title: 'Remove this line?',
      message: item.name,
      confirmLabel: 'Remove',
      icon: Icons.delete_forever_rounded,
      accentColor: const Color(0xFFFF7B6B),
    );
    return result == true;
  }
}

class _CartSiteSection extends StatefulWidget {
  const _CartSiteSection({
    required this.site,
    required this.smPickerReps,
    required this.resolvedServerSmId,
    required this.isSpaceExpanded,
    required this.onToggleSpaceExpanded,
    required this.onToggleSiteSelected,
    required this.onToggleItemSelected,
    required this.onChangeQuantity,
    required this.onDeleteItem,
    required this.onRemarkChanged,
    required this.onChangeSpec,
    required this.onSiteSmSelectionReported,
    required this.isSiteBusy,
    required this.isItemBusy,
    required this.isRemoveActionLoading,
    required this.isChangeSpecLoading,
  });

  final CartSiteDto site;

  /// SM 候选项：站点无列表时与校验一致，回退到部门（分组）级。
  final List<CartSalesRepDto> smPickerReps;

  /// 服务端已选 SM：`site` 与部门分组择非零。
  final int resolvedServerSmId;

  final bool Function(CartSpaceDto space) isSpaceExpanded;
  final void Function(CartSpaceDto space) onToggleSpaceExpanded;
  final Future<bool> Function(bool selected) onToggleSiteSelected;
  final Future<bool> Function(int itemId, bool selected) onToggleItemSelected;
  final Future<bool> Function(CartProductDto item, int nextProductNum)
  onChangeQuantity;
  final Future<bool> Function(CartProductDto item) onDeleteItem;
  final void Function(int cartId, String remark) onRemarkChanged;
  final Future<void> Function(CartProductDto item) onChangeSpec;
  final void Function(int companyId, int smId) onSiteSmSelectionReported;
  final bool isSiteBusy;
  final bool Function(int itemId) isItemBusy;
  final bool Function(int itemId) isRemoveActionLoading;
  final bool Function(int itemId) isChangeSpecLoading;

  @override
  State<_CartSiteSection> createState() => _CartSiteSectionState();
}

class _CartSiteSectionState extends State<_CartSiteSection> {
  int? _selectedSalesRepId;

  int _effectiveSelectedSmId() {
    final sid = _selectedSalesRepId;
    if (sid != null) {
      for (final r in widget.smPickerReps) {
        if (r.id == sid) return sid;
      }
    }
    return widget.resolvedServerSmId;
  }

  void _reportSmToParent() {
    widget.onSiteSmSelectionReported(
      widget.site.companyId,
      _effectiveSelectedSmId(),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedSalesRepId = widget.resolvedServerSmId > 0
        ? widget.resolvedServerSmId
        : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSmToParent());
  }

  @override
  void didUpdateWidget(covariant _CartSiteSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final companyChanged = oldWidget.site.companyId != widget.site.companyId;
    final smServerChanged =
        oldWidget.resolvedServerSmId != widget.resolvedServerSmId;
    final repsChanged = !identical(oldWidget.smPickerReps, widget.smPickerReps);
    if (companyChanged || smServerChanged || repsChanged) {
      _selectedSalesRepId = widget.resolvedServerSmId > 0
          ? widget.resolvedServerSmId
          : null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportSmToParent());
    }
  }

  CartSalesRepDto? get _selectedSalesRep {
    for (final rep in widget.smPickerReps) {
      if (rep.id == _selectedSalesRepId) return rep;
    }
    return null;
  }

  bool get _siteHasItems {
    return widget.site.cart.items.expand((space) => space.list).isNotEmpty;
  }

  bool get _siteAllSelected {
    final items = widget.site.cart.items
        .expand((space) => space.list)
        .toList(growable: false);
    if (items.isEmpty) return false;
    return items.every((item) => item.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    final selectedSalesRep = _selectedSalesRep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SmallCheckSquareCheckboxWidget(
                    value: _siteAllSelected,
                    touchExtent: 34,
                    onChanged: _siteHasItems && !widget.isSiteBusy
                        ? (selected) {
                            unawaited(widget.onToggleSiteSelected(selected));
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          widget.site.shopName.isEmpty
                              ? 'Department'
                              : widget.site.shopName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: ProMaxTokens.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.2,
                                leadingDistribution:
                                    TextLeadingDistribution.even,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 86),
                        child: Container(
                          child: UnconstrainedBox(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${widget.site.cart.totalNum} ITEMS',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CartSalesRepPicker(
                        reps: widget.smPickerReps,
                        selected: selectedSalesRep,
                        onChanged: (next) {
                          setState(() => _selectedSalesRepId = next.id);
                          _reportSmToParent();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...widget.site.cart.items.map(
          (space) => _CartSpaceSection(
            space: space,
            isExpanded: widget.isSpaceExpanded(space),
            onToggleExpanded: () => widget.onToggleSpaceExpanded(space),
            onToggleItemSelected: widget.onToggleItemSelected,
            onChangeQuantity: widget.onChangeQuantity,
            onDeleteItem: widget.onDeleteItem,
            onRemarkChanged: widget.onRemarkChanged,
            onChangeSpec: widget.onChangeSpec,
            isItemBusy: widget.isItemBusy,
            isRemoveActionLoading: widget.isRemoveActionLoading,
            isChangeSpecLoading: widget.isChangeSpecLoading,
          ),
        ),
      ],
    );
  }
}

class _CartSalesRepPicker extends StatelessWidget {
  const _CartSalesRepPicker({
    required this.reps,
    required this.selected,
    required this.onChanged,
  });

  final List<CartSalesRepDto> reps;
  final CartSalesRepDto? selected;
  final ValueChanged<CartSalesRepDto> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasReps = reps.isNotEmpty;
    final display = selected?.name.trim().isNotEmpty == true
        ? selected!.name
        : (hasReps ? 'Select SM' : 'No SM');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: hasReps ? () => _openPicker(context) : null,
        child: Opacity(
          opacity: hasReps ? 1 : 0.55,
          child: Ink(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SalesRepAvatar(url: selected?.avatar),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: hasReps ? Colors.white70 : Colors.white38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    if (reps.isEmpty) return;
    final selectedRep = await showModalBottomSheet<CartSalesRepDto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final keyboardBottom = MediaQuery.viewInsetsOf(sheetContext).bottom;
        var query = '';
        return AnimatedPadding(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: keyboardBottom),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.56,
                minChildSize: 0.32,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  final filtered = reps
                      .where((rep) {
                        final keyword = query.trim().toLowerCase();
                        if (keyword.isEmpty) return true;
                        final name = rep.name.toLowerCase();
                        final dept = rep.deptName.toLowerCase();
                        final phone = (rep.telephone ?? '').toLowerCase();
                        return name.contains(keyword) ||
                            dept.contains(keyword) ||
                            phone.contains(keyword);
                      })
                      .toList(growable: false);
                  return DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1D24),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      border: Border(top: BorderSide(color: Color(0x44FFFFFF))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Sales Rep',
                                style: TextStyle(
                                  color: ProMaxTokens.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) =>
                                  setSheetState(() => query = value),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 220,
                                ),
                                child: filtered.isEmpty
                                    ? const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.inbox_outlined,
                                              color: Colors.white54,
                                              size: 26,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'No matching sales rep',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.separated(
                                        controller: scrollController,
                                        itemCount: filtered.length,
                                        separatorBuilder: (_, __) => Divider(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                        ),
                                        itemBuilder: (context, index) {
                                          final rep = filtered[index];
                                          return ListTile(
                                            dense: true,
                                            leading: _SalesRepAvatar(
                                              url: rep.avatar,
                                            ),
                                            title: Text(
                                              rep.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              rep.deptName,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onTap: () => Navigator.of(
                                              sheetContext,
                                            ).pop(rep),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
    if (selectedRep != null) {
      onChanged(selectedRep);
    }
  }
}

class _SalesRepAvatar extends StatelessWidget {
  const _SalesRepAvatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = url?.trim() ?? '';
    return ClipOval(
      child: SizedBox(
        width: 22,
        height: 22,
        child: avatarUrl.isEmpty
            ? Container(
                color: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 14, color: Colors.white),
              )
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}

class _CartSpaceSection extends StatelessWidget {
  const _CartSpaceSection({
    required this.space,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onToggleItemSelected,
    required this.onChangeQuantity,
    required this.onDeleteItem,
    required this.onRemarkChanged,
    required this.onChangeSpec,
    required this.isItemBusy,
    required this.isRemoveActionLoading,
    required this.isChangeSpecLoading,
  });

  final CartSpaceDto space;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final Future<bool> Function(int itemId, bool selected) onToggleItemSelected;
  final Future<bool> Function(CartProductDto item, int nextProductNum)
  onChangeQuantity;
  final Future<bool> Function(CartProductDto item) onDeleteItem;
  final void Function(int cartId, String remark) onRemarkChanged;
  final Future<void> Function(CartProductDto item) onChangeSpec;
  final bool Function(int itemId) isItemBusy;
  final bool Function(int itemId) isRemoveActionLoading;
  final bool Function(int itemId) isChangeSpecLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  Text(
                    space.name.isEmpty ? 'Space' : space.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    size: 16,
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                children: space.list
                    .map(
                      (item) => _CartProductTile(
                        key: ValueKey<int>(item.id),
                        item: item,
                        onToggleItemSelected: onToggleItemSelected,
                        onChangeQuantity: onChangeQuantity,
                        onDeleteItem: onDeleteItem,
                        onRemarkChanged: onRemarkChanged,
                        onChangeSpec: onChangeSpec,
                        isBusy: isItemBusy(item.id),
                        isRemoveActionLoading: isRemoveActionLoading(item.id),
                        isChangeSpecLoading: isChangeSpecLoading(item.id),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            secondChild: const SizedBox(height: 0),
          ),
        ],
      ),
    );
  }
}

class _CartProductTile extends StatefulWidget {
  const _CartProductTile({
    super.key,
    required this.item,
    required this.onToggleItemSelected,
    required this.onChangeQuantity,
    required this.onDeleteItem,
    required this.onRemarkChanged,
    required this.onChangeSpec,
    required this.isBusy,
    required this.isRemoveActionLoading,
    required this.isChangeSpecLoading,
  });

  final CartProductDto item;
  final Future<bool> Function(int itemId, bool selected) onToggleItemSelected;
  final Future<bool> Function(CartProductDto item, int nextProductNum)
  onChangeQuantity;
  final Future<bool> Function(CartProductDto item) onDeleteItem;
  final void Function(int cartId, String remark) onRemarkChanged;
  final Future<void> Function(CartProductDto item) onChangeSpec;
  final bool isBusy;
  final bool isRemoveActionLoading;
  final bool isChangeSpecLoading;

  @override
  State<_CartProductTile> createState() => _CartProductTileState();
}

class _CartProductTileState extends State<_CartProductTile> {
  late final TextEditingController _remarkController;
  FocusNode? _remarkFocusNode;
  Timer? _quantityPressTimer;
  bool _isAdjustingQuantity = false;

  FocusNode get _safeRemarkFocusNode {
    return _remarkFocusNode ??= FocusNode();
  }

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.item.remark);
  }

  @override
  void didUpdateWidget(covariant _CartProductTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.remark != widget.item.remark &&
        _remarkController.text != widget.item.remark) {
      _remarkController.text = widget.item.remark;
    }
  }

  @override
  void dispose() {
    _quantityPressTimer?.cancel();
    _remarkController.dispose();
    _remarkFocusNode?.dispose();
    super.dispose();
  }

  Future<void> _changeQuantityByDelta(int delta) async {
    if (_isAdjustingQuantity || widget.isBusy) return;
    final next = widget.item.productNum + delta;
    if (next < 1) return;
    _isAdjustingQuantity = true;
    try {
      await widget.onChangeQuantity(widget.item, next);
    } finally {
      _isAdjustingQuantity = false;
    }
  }

  void _startContinuousAdjust(int delta) {
    if (widget.isBusy) return;
    _stopContinuousAdjust();
    _quantityPressTimer = Timer.periodic(const Duration(milliseconds: 220), (
      _,
    ) {
      unawaited(_changeQuantityByDelta(delta));
    });
  }

  void _stopContinuousAdjust() {
    _quantityPressTimer?.cancel();
    _quantityPressTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SmallCheckSquareCheckboxWidget(
              value: widget.item.isSelected,
              onChanged: widget.isBusy
                  ? null
                  : (selected) =>
                        widget.onToggleItemSelected(widget.item.id, selected),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.item.mainImage,
                width: 130,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0x33222222),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.item.subName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '\$${widget.item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            _QuantityControlButton(
                              icon: Icons.remove,
                              enabled:
                                  !widget.isBusy && widget.item.productNum > 1,
                              onTap: () => _changeQuantityByDelta(-1),
                              onLongPressStart: () =>
                                  _startContinuousAdjust(-1),
                              onLongPressEnd: _stopContinuousAdjust,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.item.productNum} ${widget.item.unit}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _QuantityControlButton(
                              icon: Icons.add,
                              enabled: !widget.isBusy,
                              onTap: () => _changeQuantityByDelta(1),
                              onLongPressStart: () => _startContinuousAdjust(1),
                              onLongPressEnd: _stopContinuousAdjust,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: SizedBox(
                              height: 30,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextField(
                                  controller: _remarkController,
                                  focusNode: _safeRemarkFocusNode,
                                  scrollPadding: EdgeInsets.only(
                                    bottom:
                                        24 +
                                        MediaQuery.viewInsetsOf(context).bottom,
                                  ),
                                  onChanged: (value) => widget.onRemarkChanged(
                                    widget.item.id,
                                    value,
                                  ),
                                  readOnly: widget.isBusy,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    prefixIcon: Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: Colors.white54,
                                    ),
                                    prefixIconConstraints: BoxConstraints(
                                      minWidth: 26,
                                      maxWidth: 26,
                                    ),
                                    hintText: 'Please edit content',
                                    hintStyle: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 7,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: widget.isBusy
                            ? null
                            : () => widget.onDeleteItem(widget.item),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(0, 22),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.white70,
                          disabledForegroundColor: Colors.white30,
                        ),
                        icon: widget.isRemoveActionLoading
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              )
                            : const Icon(Icons.delete_outline, size: 14),
                        label: const Text(
                          'REMOVE',
                          style: TextStyle(fontSize: 10, letterSpacing: 0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: widget.isBusy
                            ? null
                            : () => widget.onChangeSpec(widget.item),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(0, 22),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.white70,
                          disabledForegroundColor: Colors.white30,
                        ),
                        icon: widget.isChangeSpecLoading
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              )
                            : const Icon(Icons.tune, size: 14),
                        label: Text(
                          'EDIT',
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControlButton extends StatelessWidget {
  const _QuantityControlButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final IconData icon;
  final bool enabled;
  final Future<void> Function() onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => unawaited(onTap()) : null,
      onLongPressStart: enabled && onLongPressStart != null
          ? (_) => onLongPressStart!()
          : null,
      onLongPressEnd: enabled && onLongPressEnd != null
          ? (_) => onLongPressEnd!()
          : null,
      onLongPressCancel: enabled && onLongPressEnd != null
          ? onLongPressEnd
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? Colors.white : Colors.white30,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: ProMaxTokens.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: ProMaxTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
