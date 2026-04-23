import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/features/auth/controllers/session_providers.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_space_input_dialog.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_mall_confirm_dialog.dart';
import 'package:george_pick_mate/features/cart/controllers/cart_providers.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_config_dto.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_export_result_dto.dart';
import 'package:george_pick_mate/features/cart/presentation/widgets/cart_quotation_form_bottom_sheet_widget.dart';
import 'package:george_pick_mate/features/product/controllers/product_providers.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_sku_cart_side_sheet_widget.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/shared/widgets/home_main_content_slot_widget.dart';
import 'package:george_pick_mate/shared/widgets/app_empty_view.dart';
import 'package:george_pick_mate/shared/widgets/app_error_view.dart';
import 'package:george_pick_mate/shared/widgets/app_loading_view.dart';
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
  bool _isCheckingOut = false;
  bool _isExportingQuotationConfig = false;
  String? _exportQuotationErrorMessage;
  final NumberFormat _amountFormatter = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cartState = ref.watch(cartControllerProvider);
    final totalCount = ref.watch(cartListBadgeCountProvider);
    final selectedCount = ref.watch(cartSelectedCountProvider);
    final selectedAmount = ref.watch(cartSelectedAmountProvider);
    final canExportQuotation =
        ref.watch(canExportQuotationProvider).asData?.value ?? false;
    return cartState.when(
      loading: () => const HomeMainContentSlot(child: AppLoadingView()),
      error: (error, _) => HomeMainContentSlot(
        child: AppErrorView(message: l10n.cartLoadFailed(error.toString())),
      ),
      data: (groups) {
        final sites = groups
            .expand((group) => group.items)
            .toList(growable: false);
        if (sites.isEmpty) {
          return HomeMainContentSlot(
            child: AppEmptyView(message: l10n.cartEmpty),
          );
        }

        final isWide = MediaQuery.sizeOf(context).width >= 1120;
        final listPanel = _buildCuratedListPanel(context, sites);
        final summaryPanel = _buildSummaryPanel(
          context,
          selectedCount: selectedCount,
          selectedAmount: selectedAmount,
          totalCount: totalCount,
          canExportQuotation: canExportQuotation,
          isExportingQuotationConfig: _isExportingQuotationConfig,
          exportQuotationErrorMessage: _exportQuotationErrorMessage,
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

  Widget _buildCuratedListPanel(BuildContext context, List<CartSiteDto> sites) {
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
              '${sites.length} EXCLUSIVE SECTIONS SELECTED',
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
                itemCount: sites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, index) {
                  final site = sites[index];
                  return _CartSiteSection(
                    site: site,
                    isSpaceExpanded: (space) => _isSpaceExpanded(site, space),
                    onToggleSpaceExpanded: (space) => _toggleSpace(site, space),
                    onToggleSiteSelected: (selected) =>
                        _onToggleSiteSelected(site, selected),
                    onToggleItemSelected: (itemId, selected) =>
                        _onToggleItemSelected(itemId, selected),
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

  Widget _buildSummaryPanel(
    BuildContext context, {
    required int selectedCount,
    required double selectedAmount,
    required int totalCount,
    required bool canExportQuotation,
    required bool isExportingQuotationConfig,
    required String? exportQuotationErrorMessage,
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
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selectedCount <= 0 || _isCheckingOut
                      ? null
                      : _onCheckout,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isCheckingOut
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Go To Checkout'),
                      if (!_isCheckingOut) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 14),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isClearingAll ? null : _onClearAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.38),
                    ),
                  ),
                  child: _isClearingAll
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Clear'),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            if (canExportQuotation) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: selectedCount <= 0 || isExportingQuotationConfig
                      ? null
                      : _onExportQuotation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  icon: isExportingQuotationConfig
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_outlined, size: 16),
                  label: Text(
                    isExportingQuotationConfig ? 'Loading...' : 'Export',
                  ),
                ),
              ),
              if (exportQuotationErrorMessage != null) ...[
                const SizedBox(height: 8),
                SelectableText.rich(
                  TextSpan(
                    text: exportQuotationErrorMessage,
                    style: const TextStyle(
                      color: Color(0xFFFF6E76),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
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
    final messenger = ScaffoldMessenger.of(context);
    final current =
        ref.read(cartControllerProvider).asData?.value ?? const <CartListDto>[];
    final selectedIds = current
        .expand((group) => group.items)
        .expand((site) => site.cart.items)
        .expand((space) => space.list)
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toSet()
        .toList(growable: false);
    final hasSelectedItems = selectedIds.isNotEmpty;

    final confirmed = await showMallConfirmDialog(
      context: context,
      title: hasSelectedItems
          ? 'Remove selected lines?'
          : 'Clear entire shortlist?',
      message: hasSelectedItems
          ? '${selectedIds.length} selected lines will be removed from '
                'your shortlist.'
          : 'This clears all cart lines currently loaded for your sites.',
      confirmLabel: hasSelectedItems ? 'Remove' : 'Clear all',
      icon: hasSelectedItems
          ? Icons.delete_sweep_rounded
          : Icons.cleaning_services_rounded,
      accentColor: hasSelectedItems
          ? const Color(0xFFFF7B6B)
          : const Color(0xFFFFB86B),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _isClearingAll = true);
    final ok = hasSelectedItems
        ? await ref.read(cartControllerProvider.notifier).removeSelectedItems()
        : await ref.read(cartControllerProvider.notifier).clearAllSitesCart();
    if (!mounted) return;
    setState(() => _isClearingAll = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (hasSelectedItems ? '已删除选中商品' : '购物车已清空')
              : (hasSelectedItems ? '删除选中失败，请稍后再试' : '清空失败，请稍后再试'),
        ),
      ),
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

  Future<void> _onCheckout() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isCheckingOut = true);
    final payload = ref
        .read(cartControllerProvider.notifier)
        .buildCreateBySitesPayload();
    if (payload.cart.isEmpty) {
      if (mounted) setState(() => _isCheckingOut = false);
      return;
    }
    final ok = await ref
        .read(cartControllerProvider.notifier)
        .createOrderBySites(companyIds: payload.companyIds, cart: payload.cart);
    if (!mounted) return;
    setState(() => _isCheckingOut = false);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(content: Text('Checkout failed')));
      return;
    }
    await ref.read(cartControllerProvider.notifier).refresh();
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Order created successfully')),
    );
  }

  Future<void> _onExportQuotation() async {
    if (_isExportingQuotationConfig) return;
    setState(() {
      _isExportingQuotationConfig = true;
      _exportQuotationErrorMessage = null;
    });
    final ApiResult<CartQuotationConfigDto> result = await ref
        .read(cartControllerProvider.notifier)
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
    log('quotation export form values: $values', name: 'cart.export.quotation');
    setState(() {
      _isExportingQuotationConfig = true;
      _exportQuotationErrorMessage = null;
    });
    final exportResult = await ref
        .read(cartControllerProvider.notifier)
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
        .read(cartControllerProvider.notifier)
        .previewQuotation(formData: formData);
    if (result is ApiFailure<String>) {
      return result.exception.message;
    }
    final previewUrl = (result as ApiSuccess<String>).data;
    if (!mounted) return null;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CartQuotationPreviewPage(previewUrl: previewUrl),
      ),
    );
    return null;
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

class _CartSiteSection extends StatelessWidget {
  const _CartSiteSection({
    required this.site,
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /*  Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: allSelected,
                        onChanged: hasItems && !isSiteBusy
                            ? (value) => onToggleSiteSelected(value ?? false)
                            : null,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),*/
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          site.shopName.isEmpty ? 'Department' : site.shopName,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${site.cart.totalNum} ITEMS',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            height: 1.0,
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
        ...site.cart.items.map(
          (space) => _CartSpaceSection(
            space: space,
            isExpanded: isSpaceExpanded(space),
            onToggleExpanded: () => onToggleSpaceExpanded(space),
            onToggleItemSelected: onToggleItemSelected,
            onChangeQuantity: onChangeQuantity,
            onDeleteItem: onDeleteItem,
            onRemarkChanged: onRemarkChanged,
            onChangeSpec: onChangeSpec,
            isItemBusy: isItemBusy,
            isRemoveActionLoading: isRemoveActionLoading,
            isChangeSpecLoading: isChangeSpecLoading,
          ),
        ),
      ],
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

class _CartQuotationPreviewPage extends StatefulWidget {
  const _CartQuotationPreviewPage({required this.previewUrl});

  final String previewUrl;

  @override
  State<_CartQuotationPreviewPage> createState() =>
      _CartQuotationPreviewPageState();
}

class _CartQuotationPreviewPageState extends State<_CartQuotationPreviewPage> {
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
                  name: 'cart.quotation.preview',
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
