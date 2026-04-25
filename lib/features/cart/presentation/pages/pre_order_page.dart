import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/models/cart_list_dto.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_config_dto.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_export_result_dto.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_clear_all_confirm_flow.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_quotation_form_bottom_sheet_widget.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_sku_cart_side_sheet_widget.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_back_button.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_checkbox_button.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_filled_button.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_outlined_button.dart';
import 'package:george_pick_mate/shared/base_widget/buttons/george_quantity_control.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/adaptive_scaffold.dart';
import 'package:george_pick_mate/shared/widgets/app_empty_view.dart';
import 'package:george_pick_mate/shared/widgets/app_error_view.dart';
import 'package:george_pick_mate/shared/widgets/app_loading_view.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_george_confirm_dialog.dart';
import 'package:george_pick_mate/shared/services/app_message_service.dart';
import 'package:george_pick_mate/shared/widgets/home_main_content_slot_widget.dart';
import 'package:george_pick_mate/theme/pro_max_tokens.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 预订单：列表交互与购物车一致，样式可自行在本文件调整。
class PreOrderPage extends ConsumerStatefulWidget {
  const PreOrderPage({super.key});

  @override
  ConsumerState<PreOrderPage> createState() => _PreOrderPageState();
}

class _PreOrderPageState extends ConsumerState<PreOrderPage> {
  final Set<String> _collapsedSpaceKeys = <String>{};
  final Set<int> _pendingItemIds = <int>{};
  final Set<int> _removeActionLoadingItemIds = <int>{};
  final Set<int> _changeSpecLoadingItemIds = <int>{};
  final Set<int> _pendingSiteIds = <int>{};
  bool _isExportingQuotationConfig = false;
  String? _exportQuotationErrorMessage;
  bool _isCheckingOut = false;
  bool _isClearingAll = false;

  @override
  Widget build(BuildContext context) {
    final pre = ref.watch(preOrderCartControllerProvider);
    final canExportQuotation =
        ref.watch(canExportQuotationProvider).asData?.value ?? false;
    final selectedCount = ref.watch(preOrderSelectedCountProvider);
    return AdaptiveScaffold(
      title: 'Pre Order',
      bottomBarVisibility: AdaptiveBottomBarVisibility.never,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            HomeMainContentSlot(
              child: pre.when(
                loading: () => const AppLoadingView(),
                error: (error, _) => AppErrorView(
                  message: 'Pre order load failed: $error',
                  onRetry: () => ref
                      .read(preOrderCartControllerProvider.notifier)
                      .refresh(),
                ),
                data: (groups) {
                  final siteCount = groups.fold<int>(
                    0,
                    (sum, g) => sum + g.items.length,
                  );
                  if (siteCount == 0) {
                    return const AppEmptyView(message: 'No pre-order items');
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 60),
                      Expanded(
                        child: _buildCuratedListPanel(context, groups),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10,
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).padding.bottom + 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(text: 'Total: '),
                                      TextSpan(
                                        text: '$selectedCount',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(text: ' items'),
                                    ],
                                  ),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GeorgeOutlinedButton(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.38,
                                          ),
                                        ),
                                        isLoading: _isClearingAll,
                                        onPressed: _onClearAllPreOrder,
                                        child: const Text('Clear'),
                                      ),
                                      const SizedBox(width: 8),
                                      if (canExportQuotation)
                                        GeorgeOutlinedButton(
                                          foregroundColor: Colors.white70,
                                          side: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.28,
                                            ),
                                          ),
                                          startIcon: Icons.ios_share_outlined,
                                          iconSize: 16,
                                          iconGap: 8,
                                          isLoading:
                                              _isExportingQuotationConfig,
                                          onPressed: selectedCount <= 0
                                              ? null
                                              : _onExportQuotation,
                                          child: const Text('Export'),
                                        ),
                                      if (canExportQuotation)
                                        const SizedBox(width: 8),
                                      GeorgeFilledButton(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        endIcon: Icons.arrow_forward,
                                        iconSize: 14,
                                        iconGap: 8,
                                        isLoading: _isCheckingOut,
                                        loadingIndicatorSize: 16,
                                        onPressed: selectedCount <= 0
                                            ? null
                                            : _onCheckout,
                                        child: const Text('Go To Checkout'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (canExportQuotation &&
                                _exportQuotationErrorMessage != null) ...[
                              const SizedBox(height: 8),
                              SelectableText.rich(
                                TextSpan(
                                  text: _exportQuotationErrorMessage,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6E76),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              left: 18,
              top: 12,
              child: GeorgeBackButton(
                label: 'Back Cart',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
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
      onRefresh: () =>
          ref.read(preOrderCartControllerProvider.notifier).refresh(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: siteEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, index) {
                  final e = siteEntries[index];
                  final grp = e.group;
                  final site = e.site;
                  final smPickerReps = site.smItems.isNotEmpty
                      ? site.smItems
                      : grp.smItems;
                  final resolvedSmId =
                      site.smId > 0 ? site.smId : grp.smId;
                  return _CartSiteSection(
                    site: site,
                    shopDepartmentId: grp.id,
                    smPickerReps: smPickerReps,
                    resolvedServerSmId: resolvedSmId,
                    onSalesRepSelected: (rep) => _onPreOrderSmSelected(
                      shopDepartmentId: grp.id,
                      smId: rep.id,
                    ),
                    isSpaceExpanded: (space) =>
                        _isSpaceExpanded(site, space),
                    onToggleSpaceExpanded: (space) =>
                        _toggleSpace(site, space),
                    onToggleSiteSelected: (selected) =>
                        _onToggleSiteSelected(site, selected),
                    onToggleItemSelected: _onToggleItemSelected,
                    onChangeQuantity: _onChangeQuantity,
                    onDeleteItem: _onDeleteItem,
                    onRemarkChanged: _onRemarkChanged,
                    onChangeSpec: _onChangeSpec,
                    isSiteBusy: _pendingSiteIds.contains(site.companyId),
                    isItemBusy: (itemId) =>
                        _pendingItemIds.contains(itemId) ||
                        _pendingSiteIds.contains(site.companyId),
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

  Future<void> _onPreOrderSmSelected({
    required int shopDepartmentId,
    required int smId,
  }) async {
    final result = await ref
        .read(preOrderCartControllerProvider.notifier)
        .saveSmForShopDepartment(
          shopDepartmentId: shopDepartmentId,
          smId: smId,
        );
    if (!mounted) return;
    result.when(
      success: (_) {},
      failure: (e) => showGlobalErrorMessage(e.message),
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

  Future<void> _onClearAllPreOrder() async {
    final current =
        ref.read(preOrderCartControllerProvider).asData?.value ??
        const <CartListDto>[];
    await runCartClearAllConfirmFlow(
      context: context,
      currentGroups: current,
      cartNotifier: ref.read(preOrderCartControllerProvider.notifier),
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
        .read(preOrderCartControllerProvider.notifier)
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
          .read(preOrderCartControllerProvider.notifier)
          .toggleProductSelected(cartId: itemId, selected: selected),
    );
  }

  Future<bool> _onChangeQuantity(CartProductDto item, int nextProductNum) {
    if (nextProductNum < 1) return Future<bool>.value(false);
    return _runItemAction(
      item.id,
      () => ref
          .read(preOrderCartControllerProvider.notifier)
          .changeProductQuantity(cartId: item.id, productNum: nextProductNum),
    );
  }

  Future<bool> _onDeleteItem(CartProductDto item) async {
    if (_pendingItemIds.contains(item.id)) return false;
    final confirmed = await _showDeleteItemConfirmDialog(item);
    if (!mounted || !confirmed) return false;
    return _runItemAction(
      item.id,
      () => ref
          .read(preOrderCartControllerProvider.notifier)
          .removeCartItem(item.id),
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
              .read(preOrderCartControllerProvider.notifier)
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
          .read(preOrderCartControllerProvider.notifier)
          .updateProductRemark(cartId: cartId, remark: remark),
    );
  }

  Future<bool> _showDeleteItemConfirmDialog(CartProductDto item) async {
    final result = await showGeorgeConfirmDialog(
      context: context,
      title: 'Remove this line?',
      message: item.name,
      confirmLabel: 'Remove',
      icon: Icons.delete_forever_rounded,
      accentColor: const Color(0xFFFF7B6B),
    );
    return result == true;
  }

  Future<void> _onExportQuotation() async {
    if (_isExportingQuotationConfig) return;
    setState(() {
      _isExportingQuotationConfig = true;
      _exportQuotationErrorMessage = null;
    });
    final ApiResult<CartQuotationConfigDto> result = await ref
        .read(preOrderCartControllerProvider.notifier)
        .fetchQuotationConfig();
    if (!mounted) return;
    setState(() => _isExportingQuotationConfig = false);
    if (result is ApiFailure<CartQuotationConfigDto>) {
      setState(() {
        _exportQuotationErrorMessage = result.exception.message;
      });
      return;
    }
    final config = (result as ApiSuccess<CartQuotationConfigDto>).data;
    if (config.formData.isEmpty) {
      setState(() {
        _exportQuotationErrorMessage = 'Export form config is empty.';
      });
      return;
    }
    final values = await showCartQuotationFormBottomSheet(
      context: context,
      fields: config.formData,
      onPreview: _onPreviewQuotation,
    );
    if (!mounted || values == null) return;
    log(
      'quotation export form values: $values',
      name: 'pre_order.export.quotation',
    );
    setState(() {
      _isExportingQuotationConfig = true;
      _exportQuotationErrorMessage = null;
    });
    final exportResult = await ref
        .read(preOrderCartControllerProvider.notifier)
        .exportQuotation(formData: values);
    if (!mounted) return;
    setState(() => _isExportingQuotationConfig = false);
    if (exportResult is ApiFailure<CartQuotationExportResultDto>) {
      setState(() {
        _exportQuotationErrorMessage = exportResult.exception.message;
      });
      return;
    }
    final exportData =
        (exportResult as ApiSuccess<CartQuotationExportResultDto>).data;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quotation exported: ${exportData.fileName}\n${exportData.filePath}',
        ),
      ),
    );
  }

  Future<String?> _onPreviewQuotation(Map<String, dynamic> formData) async {
    final result = await ref
        .read(preOrderCartControllerProvider.notifier)
        .previewQuotation(formData: formData);
    if (result is ApiFailure<String>) {
      return result.exception.message;
    }
    final previewUrl = (result as ApiSuccess<String>).data;
    if (!mounted) return null;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PreOrderQuotationPreviewPage(previewUrl: previewUrl),
      ),
    );
    return null;
  }

  Future<void> _onCheckout() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isCheckingOut = true);
    final payload = ref
        .read(preOrderCartControllerProvider.notifier)
        .buildCreateBySitesPayload();
    if (payload.cart.isEmpty) {
      if (mounted) setState(() => _isCheckingOut = false);
      return;
    }
    final ok = await ref
        .read(preOrderCartControllerProvider.notifier)
        .createOrderBySites(companyIds: payload.companyIds, cart: payload.cart);
    if (!mounted) return;
    setState(() => _isCheckingOut = false);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(content: Text('Checkout failed')));
      return;
    }
    await ref.read(preOrderCartControllerProvider.notifier).refresh();
    ref.invalidate(cartControllerProvider);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Order created successfully')),
    );
  }
}

class _CartSiteSection extends StatefulWidget {
  const _CartSiteSection({
    required this.site,
    required this.shopDepartmentId,
    required this.smPickerReps,
    required this.resolvedServerSmId,
    required this.onSalesRepSelected,
    required this.isSpaceExpanded,
    required this.onToggleSpaceExpanded,
    required this.onToggleSiteSelected,
    required this.onToggleItemSelected,
    required this.onChangeQuantity,
    required this.onDeleteItem,
    required this.onRemarkChanged,
    required this.onChangeSpec,
    required this.isSiteBusy,
    required this.isItemBusy,
    required this.isRemoveActionLoading,
    required this.isChangeSpecLoading,
  });

  final CartSiteDto site;

  /// 列表一级部门 id，对应设置 SM 接口的 `shop_department_id`。
  final int shopDepartmentId;

  /// SM 候选项：站点无列表时回退到部门（分组）级。
  final List<CartSalesRepDto> smPickerReps;

  /// 服务端已选 SM：站点与部门分组择非零。
  final int resolvedServerSmId;

  /// 用户在预订单页选定 SM 后立即落库（与购物车预提交同一接口）。
  final Future<void> Function(CartSalesRepDto rep) onSalesRepSelected;

  final bool Function(CartSpaceDto space) isSpaceExpanded;
  final void Function(CartSpaceDto space) onToggleSpaceExpanded;
  final Future<bool> Function(bool selected) onToggleSiteSelected;
  final Future<bool> Function(int itemId, bool selected) onToggleItemSelected;
  final Future<bool> Function(CartProductDto item, int nextProductNum)
  onChangeQuantity;
  final Future<bool> Function(CartProductDto item) onDeleteItem;
  final void Function(int cartId, String remark) onRemarkChanged;
  final Future<void> Function(CartProductDto item) onChangeSpec;
  final bool isSiteBusy;
  final bool Function(int itemId) isItemBusy;
  final bool Function(int itemId) isRemoveActionLoading;
  final bool Function(int itemId) isChangeSpecLoading;

  @override
  State<_CartSiteSection> createState() => _CartSiteSectionState();
}

class _CartSiteSectionState extends State<_CartSiteSection> {
  int? _selectedSalesRepId;
  bool _isSavingSm = false;

  int _effectiveSelectedSmId() {
    final sid = _selectedSalesRepId;
    if (sid != null) {
      for (final r in widget.smPickerReps) {
        if (r.id == sid) return sid;
      }
    }
    return widget.resolvedServerSmId;
  }

  Future<void> _commitSmSelection(CartSalesRepDto next) async {
    if (widget.shopDepartmentId <= 0 ||
        next.id <= 0 ||
        _isSavingSm ||
        next.id == _effectiveSelectedSmId()) {
      return;
    }
    setState(() => _isSavingSm = true);
    try {
      await widget.onSalesRepSelected(next);
    } finally {
      if (mounted) setState(() => _isSavingSm = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedSalesRepId = widget.resolvedServerSmId > 0
        ? widget.resolvedServerSmId
        : null;
  }

  @override
  void didUpdateWidget(covariant _CartSiteSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final companyChanged =
        oldWidget.site.companyId != widget.site.companyId;
    final deptChanged =
        oldWidget.shopDepartmentId != widget.shopDepartmentId;
    final smServerChanged =
        oldWidget.resolvedServerSmId != widget.resolvedServerSmId;
    final repsChanged =
        !identical(oldWidget.smPickerReps, widget.smPickerReps);
    if (companyChanged || deptChanged || smServerChanged || repsChanged) {
      _selectedSalesRepId = widget.resolvedServerSmId > 0
          ? widget.resolvedServerSmId
          : null;
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
                  child: GeorgeCheckboxButton(
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
                      AbsorbPointer(
                        absorbing: _isSavingSm,
                        child: Opacity(
                          opacity: _isSavingSm ? 0.55 : 1,
                          child: _CartSalesRepPicker(
                            reps: widget.smPickerReps,
                            selected: selectedSalesRep,
                            onChanged: (next) {
                              unawaited(_commitSmSelection(next));
                            },
                          ),
                        ),
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
  late final FocusNode _remarkFocusNode;
  Timer? _quantityPressTimer;
  bool _isAdjustingQuantity = false;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.item.remark);
    _remarkFocusNode = FocusNode()..addListener(_onRemarkFocusChange);
  }

  void _onRemarkFocusChange() {
    if (_remarkFocusNode.hasFocus || widget.isBusy) return;
    final text = _remarkController.text;
    if (text == widget.item.remark) return;
    widget.onRemarkChanged(widget.item.id, text);
  }

  @override
  void didUpdateWidget(covariant _CartProductTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_remarkFocusNode.hasFocus) return;
    if (oldWidget.item.remark != widget.item.remark &&
        _remarkController.text != widget.item.remark) {
      _remarkController.text = widget.item.remark;
    }
  }

  @override
  void dispose() {
    _quantityPressTimer?.cancel();
    _remarkFocusNode.removeListener(_onRemarkFocusChange);
    _remarkFocusNode.dispose();
    _remarkController.dispose();
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            GeorgeCheckboxButton(
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
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0x33222222),
                  child: SizedBox(
                    width: 84,
                    height: 84,
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
                                fontSize: 16,
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
                      GeorgeQuantityControl(
                        quantityText:
                            '${widget.item.productNum} ${widget.item.unit}',
                        isDecreaseEnabled:
                            !widget.isBusy && widget.item.productNum > 1,
                        isIncreaseEnabled: !widget.isBusy,
                        onDecreaseTap: () => _changeQuantityByDelta(-1),
                        onIncreaseTap: () => _changeQuantityByDelta(1),
                        onDecreaseLongPressStart: () =>
                            _startContinuousAdjust(-1),
                        onDecreaseLongPressEnd: _stopContinuousAdjust,
                        onIncreaseLongPressStart: () =>
                            _startContinuousAdjust(1),
                        onIncreaseLongPressEnd: _stopContinuousAdjust,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 290),
                                  child: SizedBox(
                                    height: 34,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: TextField(
                                        controller: _remarkController,
                                        focusNode: _remarkFocusNode,
                                        scrollPadding: EdgeInsets.only(
                                          bottom:
                                              24 +
                                              MediaQuery.viewInsetsOf(
                                                context,
                                              ).bottom,
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
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline, size: 14),
                              label: const Text(
                                'REMOVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                ),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.tune, size: 14),
                              label: const Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ],
      ),
    );
  }
}

class _PreOrderQuotationPreviewPage extends StatefulWidget {
  const _PreOrderQuotationPreviewPage({required this.previewUrl});

  final String previewUrl;

  @override
  State<_PreOrderQuotationPreviewPage> createState() =>
      _PreOrderQuotationPreviewPageState();
}

class _PreOrderQuotationPreviewPageState
    extends State<_PreOrderQuotationPreviewPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _loadError;

  bool _shouldIgnoreWebResourceError(WebResourceError error) {
    final isMainFrame = error.isForMainFrame;
    if (isMainFrame == false) {
      return true;
    }
    final description = error.description.toLowerCase();
    if (description.contains('preloaded using link preload')) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (!mounted) return;
              setState(() {
                _isLoading = true;
                _loadError = null;
              });
            },
            onPageFinished: (_) {
              if (!mounted) return;
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (error) {
              if (!mounted) return;
              if (_shouldIgnoreWebResourceError(error)) {
                log(
                  'Quotation preview ignored web error: '
                  '${error.description}',
                  name: 'pre_order.quotation.preview',
                );
                return;
              }
              setState(() {
                _isLoading = false;
                _loadError = error.description;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.previewUrl));
    } catch (e) {
      _loadError = e.toString();
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SelectableText.rich(
            TextSpan(
              text: _loadError ?? 'Preview is not available on this device.',
              style: const TextStyle(
                color: Color(0xFFFF6E76),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading)
          const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        if (_loadError != null)
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Material(
              color: const Color(0xDD3A2022),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SelectableText.rich(
                  TextSpan(
                    text: _loadError,
                    style: const TextStyle(
                      color: Color(0xFFFFB5BB),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
