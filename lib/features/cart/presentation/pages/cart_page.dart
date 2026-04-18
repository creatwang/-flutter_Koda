import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/cart/controllers/cart_providers.dart';
import 'package:groe_app_pad/features/order/controllers/order_providers.dart';
import 'package:intl/intl.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';
import 'package:groe_app_pad/shared/widgets/pro_max_glass_card_widget.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

import '../../models/cart_list_dto.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final Set<String> _collapsedSpaceKeys = <String>{};
  final Set<int> _pendingItemIds = <int>{};
  final Set<int> _pendingSiteIds = <int>{};
  bool _isClearingAll = false;
  bool _isCheckingOut = false;
  final NumberFormat _amountFormatter = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cartState = ref.watch(cartControllerProvider);
    final totalCount = ref.watch(cartBadgeCountProvider);
    final selectedCount = ref.watch(cartSelectedCountProvider);
    final selectedAmount = ref.watch(cartSelectedAmountProvider);
    final canExportQuotation =
        ref.watch(canExportQuotationProvider).asData?.value ?? false;
    return cartState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) =>
          AppErrorView(message: l10n.cartLoadFailed(error.toString())),
      data: (groups) {
        final sites = groups
            .expand((group) => group.items)
            .toList(growable: false);
        if (sites.isEmpty) return AppEmptyView(message: l10n.cartEmpty);

        final isWide = MediaQuery.sizeOf(context).width >= 1120;
        final listPanel = _buildCuratedListPanel(context, sites);
        final summaryPanel = _buildSummaryPanel(
          context,
          selectedCount: selectedCount,
          selectedAmount: selectedAmount,
          totalCount: totalCount,
          canExportQuotation: canExportQuotation,
        );

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: listPanel),
                const SizedBox(width: 18),
                SizedBox(width: 330, child: summaryPanel),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(child: listPanel),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: summaryPanel,
              ),
            ),
          ],
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
                    onDeleteItem: _onDeleteItem,
                    onRemarkChanged: _onRemarkChanged,
                    isSiteBusy: _pendingSiteIds.contains(site.companyId),
                    isItemBusy: (itemId) =>
                        _pendingItemIds.contains(itemId) ||
                        _pendingSiteIds.contains(site.companyId),
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
                '¥${_amountFormatter.format(selectedAmount)}',
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
                    minimumSize: const Size.fromHeight(46), // 保持高度 46
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 居中显示
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. 先放文字或加载动画
                      _isCheckingOut
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white, // 确保加载圈在黑色背景上可见
                              ),
                            )
                          : const Text('Go To Checkout'),

                      // 2. 如果不在加载中，则在文字后显示图标
                      if (!_isCheckingOut) ...[
                        const SizedBox(width: 8), // 文字和图标的间距
                        const Icon(
                          Icons.arrow_forward,
                          size: 14,
                        ), // 注意：通常 Go To 建议用 arrow_forward
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
        if (canExportQuotation) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
              ),
              icon: const Icon(Icons.ios_share_outlined, size: 16),
              label: const Text('Export'),
            ),
          ),
        ],
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
    final confirmed = await _showClearConfirmDialog(
      title: '确认清空购物车？',
      message: '此操作会清空当前已加载站点的全部购物车内容。',
    );
    if (!mounted || !confirmed) return;
    setState(() => _isClearingAll = true);
    final ok = await ref
        .read(cartControllerProvider.notifier)
        .clearAllSitesCart();
    if (!mounted) return;
    setState(() => _isClearingAll = false);
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? '购物车已清空' : '清空失败，请稍后再试')),
    );
  }

  Future<void> _onCheckout() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isCheckingOut = true);
    final payload = ref
        .read(cartControllerProvider.notifier)
        .buildCreateBySitesPayload();
    if (payload.cart.isEmpty) {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
      return;
    }
    final ok = await ref
        .read(ordersProvider.notifier)
        .createOrderBySites(companyIds: payload.companyIds, cart: payload.cart);
    if (!mounted) return;
    setState(() => _isCheckingOut = false);
    if (ok) {
      await ref.read(cartControllerProvider.notifier).refresh();
      if (!mounted) return;
      await _showOrderSuccessDialog();
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.orderCreateFailed)),
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

  Future<bool> _onDeleteItem(CartProductDto item) async {
    if (_pendingItemIds.contains(item.id)) return false;
    final confirmed = await _showDeleteItemConfirmDialog(item);
    if (!mounted || !confirmed) return false;
    return _runItemAction(
      item.id,
      () => ref.read(cartControllerProvider.notifier).removeCartItem(item.id),
    );
  }

  Future<bool> _runItemAction(
    int itemId,
    Future<bool> Function() action,
  ) async {
    if (_pendingItemIds.contains(itemId)) return false;
    setState(() => _pendingItemIds.add(itemId));
    final ok = await action();
    if (!mounted) return ok;
    setState(() => _pendingItemIds.remove(itemId));
    return ok;
  }

  void _onRemarkChanged(int cartId, String remark) {
    unawaited(
      ref
          .read(cartControllerProvider.notifier)
          .updateProductRemark(cartId: cartId, remark: remark),
    );
  }

  Future<bool> _showClearConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProMaxGlassCardWidget(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ProMaxTokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: ProMaxTokens.textSecondary.withValues(alpha: 0.92),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0x55FF6E76),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('确认清空'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result == true;
  }

  Future<bool> _showDeleteItemConfirmDialog(CartProductDto item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProMaxGlassCardWidget(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '确认删除该商品？',
                  style: TextStyle(
                    color: ProMaxTokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ProMaxTokens.textSecondary.withValues(alpha: 0.92),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0x55FF6E76),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result == true;
  }

  Future<void> _showOrderSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProMaxGlassCardWidget(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0x3324F5A6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xAA66FFD0)),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF9AF7D3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '下单成功',
                        style: TextStyle(
                          color: ProMaxTokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '订单创建完成，系统将按照站点分别处理你的下单项。',
                  style: TextStyle(
                    color: ProMaxTokens.textSecondary.withValues(alpha: 0.95),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: ProMaxTokens.buttonPrimary,
                      foregroundColor: ProMaxTokens.buttonOnPrimary,
                    ),
                    child: const Text('知道了'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartSiteSection extends StatelessWidget {
  const _CartSiteSection({
    required this.site,
    required this.isSpaceExpanded,
    required this.onToggleSpaceExpanded,
    required this.onToggleSiteSelected,
    required this.onToggleItemSelected,
    required this.onDeleteItem,
    required this.onRemarkChanged,
    required this.isSiteBusy,
    required this.isItemBusy,
  });

  final CartSiteDto site;
  final bool Function(CartSpaceDto space) isSpaceExpanded;
  final void Function(CartSpaceDto space) onToggleSpaceExpanded;
  final Future<bool> Function(bool selected) onToggleSiteSelected;
  final Future<bool> Function(int itemId, bool selected) onToggleItemSelected;
  final Future<bool> Function(CartProductDto item) onDeleteItem;
  final void Function(int cartId, String remark) onRemarkChanged;
  final bool isSiteBusy;
  final bool Function(int itemId) isItemBusy;

  @override
  Widget build(BuildContext context) {
    final allProducts = site.cart.items.expand((space) => space.list).toList();
    final hasItems = allProducts.isNotEmpty;
    final allSelected =
        hasItems && allProducts.every((item) => item.isSelected);

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
                const SizedBox(width: 8),
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
            onDeleteItem: onDeleteItem,
            onRemarkChanged: onRemarkChanged,
            isItemBusy: isItemBusy,
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
    required this.onDeleteItem,
    required this.onRemarkChanged,
    required this.isItemBusy,
  });

  final CartSpaceDto space;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final Future<bool> Function(int itemId, bool selected) onToggleItemSelected;
  final Future<bool> Function(CartProductDto item) onDeleteItem;
  final void Function(int cartId, String remark) onRemarkChanged;
  final bool Function(int itemId) isItemBusy;

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
                        onDeleteItem: onDeleteItem,
                        onRemarkChanged: onRemarkChanged,
                        isBusy: isItemBusy(item.id),
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
    required this.onDeleteItem,
    required this.onRemarkChanged,
    required this.isBusy,
  });

  final CartProductDto item;
  final Future<bool> Function(int itemId, bool selected) onToggleItemSelected;
  final Future<bool> Function(CartProductDto item) onDeleteItem;
  final void Function(int cartId, String remark) onRemarkChanged;
  final bool isBusy;

  @override
  State<_CartProductTile> createState() => _CartProductTileState();
}

class _CartProductTileState extends State<_CartProductTile> {
  late final TextEditingController _remarkController;
  FocusNode? _remarkFocusNode;

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
    _remarkController.dispose();
    _remarkFocusNode?.dispose();
    super.dispose();
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
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: widget.item.isSelected,
                onChanged: widget.isBusy
                    ? null
                    : (value) => widget.onToggleItemSelected(
                        widget.item.id,
                        value ?? false,
                      ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
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
                        '¥${widget.item.price.toStringAsFixed(0)}',
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
                        icon: const Icon(Icons.delete_outline, size: 14),
                        label: const Text(
                          'REMOVE',
                          style: TextStyle(fontSize: 10, letterSpacing: 0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: widget.isBusy
                            ? null
                            : () => _safeRemarkFocusNode.requestFocus(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(0, 22),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.white70,
                        ),
                        icon: const Icon(Icons.tune, size: 14),
                        label: const Text(
                          'EDIT',
                          style: TextStyle(fontSize: 10, letterSpacing: 0.4),
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
