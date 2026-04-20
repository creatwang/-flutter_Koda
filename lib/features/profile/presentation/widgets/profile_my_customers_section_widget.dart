import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/customer_account_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/my_customer_user_orders_providers.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_order_providers.dart';
import 'package:groe_app_pad/features/profile/models/store_customer_item_dto.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/profile_product_order_list_widget.dart';
import 'package:groe_app_pad/features/profile/presentation/widgets/store_customer_form_bottom_sheet.dart';
import 'package:groe_app_pad/shared/services/app_message_service.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 业务员客户列表：表头、列表行（代客登录等逻辑不变）。
class ProfileMyCustomersSectionWidget extends ConsumerStatefulWidget {
  const ProfileMyCustomersSectionWidget({super.key});

  @override
  ConsumerState<ProfileMyCustomersSectionWidget> createState() =>
      _ProfileMyCustomersSectionWidgetState();
}

class _ProfileMyCustomersSectionWidgetState
    extends ConsumerState<ProfileMyCustomersSectionWidget>
    with SingleTickerProviderStateMixin {
  /// 正在代客登录的客户行 `id`；非空时禁止重复点击。
  int? _loggingInCustomerId;

  /// 正在拉取订单的客户行 `id`（`StoreCustomerItemDto.id`）。
  int? _pendingOrdersRowCustomerId;

  /// 首屏订单加载成功后只触发一次划入动画。
  bool _didRunOpenSlide = false;

  bool _isClosingOrdersPanel = false;

  /// 订单层右滑关闭：与 ListView 手势竞技场解耦，用指针位移判断。
  double _orderPanelSwipeDx = 0;
  double _orderPanelSwipeDyAbs = 0;

  /// 轻甩：与 Scrollable 并行采样，在抬手时用 [VelocityTracker.getVelocity]。
  VelocityTracker? _orderPanelVelocityTracker;

  late final AnimationController _panelAnimationController;

  @override
  void initState() {
    super.initState();
    _panelAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _panelAnimationController.dispose();
    super.dispose();
  }

  int _orderListUserId(StoreCustomerItemDto item) =>
      item.userMainId > 0 ? item.userMainId : item.id;

  Future<void> _refresh() async {
    await ref.read(storeCustomersProvider.notifier).refresh();
  }

  void _loadMore() {
    ref.read(storeCustomersProvider.notifier).loadMore();
  }

  Future<void> _onLogin(StoreCustomerItemDto item) async {
    if (_loggingInCustomerId != null) return;
    setState(() => _loggingInCustomerId = item.id);
    try {
      final result = await ref
          .read(sessionControllerProvider.notifier)
          .loginAsStoreCustomer(customerRowId: item.id);
      if (!mounted) return;
      result.when(
        success: (_) {
          context.go(AppRoutes.home);
          // 先导航再提示：否则 SnackBar 绑在即将 dispose 的 subtree 上，
          // 动画回调会触发「deactivated widget's ancestor」断言。
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final messenger = appScaffoldMessengerKey.currentState;
            if (messenger == null) return;
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Logged in as customer.')),
              );
          });
        },
        failure: (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        },
      );
    } finally {
      if (mounted) setState(() => _loggingInCustomerId = null);
    }
  }

  Future<void> _confirmDelete(StoreCustomerItemDto item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer'),
        content: Text('Remove ${item.name} (${item.username})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final result = await ref
        .read(storeCustomersProvider.notifier)
        .deleteCustomer(item);
    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted')));
      },
      failure: (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      },
    );
  }

  void _onViewCustomerOrders(StoreCustomerItemDto item) {
    if (_loggingInCustomerId != null || _pendingOrdersRowCustomerId != null) {
      return;
    }
    if (_isClosingOrdersPanel) return;
    final int uid = _orderListUserId(item);
    setState(() {
      _pendingOrdersRowCustomerId = item.id;
      _didRunOpenSlide = false;
    });
    ref
        .read(myCustomerOrdersViewUserIdProvider.notifier)
        .setViewUserId(uid);
  }

  void _resetOrderPanelSwipeTracking() {
    _orderPanelSwipeDx = 0;
    _orderPanelSwipeDyAbs = 0;
    _orderPanelVelocityTracker = null;
  }

  void _onOrderPanelPointerDown(PointerDownEvent event) {
    _resetOrderPanelSwipeTracking();
    _orderPanelVelocityTracker = VelocityTracker.withKind(event.kind);
    _orderPanelVelocityTracker!.addPosition(event.timeStamp, event.position);
  }

  void _onOrderPanelPointerMove(PointerMoveEvent event) {
    _orderPanelVelocityTracker?.addPosition(event.timeStamp, event.position);
    if (_panelAnimationController.value < 0.98) return;
    _orderPanelSwipeDx += event.delta.dx;
    _orderPanelSwipeDyAbs += event.delta.dy.abs();
  }

  void _onOrderPanelPointerUp(PointerUpEvent event) {
    _orderPanelVelocityTracker?.addPosition(event.timeStamp, event.position);
    if (_panelAnimationController.value < 0.98) {
      _resetOrderPanelSwipeTracking();
      return;
    }
    final VelocityTracker? tracker = _orderPanelVelocityTracker;
    final Velocity v = tracker?.getVelocity() ?? Velocity.zero;
    final VelocityEstimate? est = tracker?.getVelocityEstimate();
    double vx = v.pixelsPerSecond.dx;
    double vy = v.pixelsPerSecond.dy;
    if (est != null && est.pixelsPerSecond.dx > vx) {
      vx = est.pixelsPerSecond.dx;
      vy = est.pixelsPerSecond.dy;
    }
    const double flickVxThreshold = 220;
    final bool flickClose =
        vx > flickVxThreshold && vx >= vy.abs() * 0.72;
    const double minRightDx = 48;
    final bool distanceClose = _orderPanelSwipeDx >= minRightDx &&
        _orderPanelSwipeDx >= _orderPanelSwipeDyAbs;
    if (flickClose || distanceClose) {
      _closeOrdersPanel();
    }
    _resetOrderPanelSwipeTracking();
  }

  void _onOrderPanelPointerCancel(PointerCancelEvent event) {
    _resetOrderPanelSwipeTracking();
  }

  void _closeOrdersPanel() {
    if (_isClosingOrdersPanel) return;
    if (!_panelAnimationController.isCompleted) return;
    _isClosingOrdersPanel = true;
    _panelAnimationController.reverse().then((_) {
      if (!mounted) return;
      ref
          .read(myCustomerOrdersViewUserIdProvider.notifier)
          .setViewUserId(null);
      ref.invalidate(myCustomerUserOrdersProvider);
      setState(() {
        _didRunOpenSlide = false;
        _pendingOrdersRowCustomerId = null;
        _isClosingOrdersPanel = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ProfileOrderListState>>(
      myCustomerUserOrdersProvider,
      (AsyncValue<ProfileOrderListState>? previous,
          AsyncValue<ProfileOrderListState> next,) {
        final int? uid = ref.read(myCustomerOrdersViewUserIdProvider);
        if (uid == null) return;
        if (next is AsyncError) {
          final bool stillOpening =
              _pendingOrdersRowCustomerId != null || !_didRunOpenSlide;
          if (stillOpening) {
            ref
                .read(myCustomerOrdersViewUserIdProvider.notifier)
                .setViewUserId(null);
            if (mounted) {
              setState(() {
                _pendingOrdersRowCustomerId = null;
                _didRunOpenSlide = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${next.error}')),
              );
            }
          }
          return;
        }
        if (next is AsyncData<ProfileOrderListState> && !_didRunOpenSlide) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (ref.read(myCustomerOrdersViewUserIdProvider) == null) return;
            setState(() {
              _didRunOpenSlide = true;
              _pendingOrdersRowCustomerId = null;
            });
            _panelAnimationController.forward();
          });
        }
      },
    );

    final Animation<double> listFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _panelAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    final Animation<Offset> ordersSlide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _panelAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    final state = ref.watch(storeCustomersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FadeTransition(
                opacity: listFade,
                child: ListenableBuilder(
                  listenable: _panelAnimationController,
                  builder: (BuildContext context, Widget? child) {
                    return IgnorePointer(
                      ignoring: _panelAnimationController.value > 0.02,
                      child: child!,
                    );
                  },
                  child: state.when(
                    loading: () => const AppLoadingView(),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText.rich(
                            TextSpan(
                              text: err.toString(),
                              style: const TextStyle(color: Color(0xFFFF6E76)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (data) {
                      if (data.items.isEmpty) {
                        return const AppEmptyView(
                          message: 'No customers',
                          width: 120,
                          height: 120,
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n.metrics.pixels >
                                n.metrics.maxScrollExtent - 320) {
                              _loadMore();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: data.items.length +
                                1 +
                                (data.isLoadingMore ? 1 : 0),
                            itemBuilder: (_, int index) {
                              if (index == 0) {
                                return const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: _MyCustomersTableHeader(),
                                );
                              }
                              final rowIndex = index - 1;
                              if (rowIndex >= data.items.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final item = data.items[rowIndex];
                              final bool loginBusy =
                                  _loggingInCustomerId != null;
                              final bool rowLoginLoading =
                                  _loggingInCustomerId == item.id;
                              final bool rowOrdersLoading =
                                  _pendingOrdersRowCustomerId == item.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CustomerRowCard(
                                  item: item,
                                  interactionLocked: loginBusy ||
                                      _pendingOrdersRowCustomerId != null,
                                  rowLoginLoading: rowLoginLoading,
                                  rowOrdersLoading: rowOrdersLoading,
                                  onViewOrders: () =>
                                      _onViewCustomerOrders(item),
                                  onEdit: () => showStoreCustomerFormBottomSheet(
                                    context: context,
                                    ref: ref,
                                    mode: StoreCustomerSheetMode.edit,
                                    editing: item,
                                  ),
                                  onDelete: () => _confirmDelete(item),
                                  onLogin: () => _onLogin(item),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SlideTransition(
                position: ordersSlide,
                child: ListenableBuilder(
                  listenable: _panelAnimationController,
                  builder: (BuildContext context, Widget? child) {
                    return IgnorePointer(
                      ignoring: _panelAnimationController.value < 0.98,
                      child: Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: _onOrderPanelPointerDown,
                        onPointerMove: _onOrderPanelPointerMove,
                        onPointerUp: _onOrderPanelPointerUp,
                        onPointerCancel: _onOrderPanelPointerCancel,
                        child: child!,
                      ),
                    );
                  },
                  child: ProfileProductOrderListWidget(
                    asyncState: ref.watch(myCustomerUserOrdersProvider),
                    onRefresh: () => ref
                        .read(myCustomerUserOrdersProvider.notifier)
                        .refresh(),
                    onLoadMore: () => ref
                        .read(myCustomerUserOrdersProvider.notifier)
                        .loadMore(),
                    showUserInfo: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 设计稿：列表列宽与行内列对齐。
class _MyCustomersColumnLayout {
  _MyCustomersColumnLayout._();

  static const double avatar = 48;
  static const double avatarNameGap = 12;
  /// 与行内「头像 + 间距」占位一致，表头文字与姓名列对齐。
  static const double nameLabelInset = avatar + avatarNameGap;

  static const double uid = 108;
  static const double actions = 132;
  static const double login = 100;
}

String _customerSecondaryLine(StoreCustomerItemDto item) {
  final String e = item.email.trim();
  return e.isNotEmpty ? e : item.username;
}

class _MyCustomersTableHeader extends StatelessWidget {
  const _MyCustomersTableHeader();

  static TextStyle _style() => TextStyle(
    color: ProMaxTokens.textSecondary.withValues(alpha: 0.75),
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: _MyCustomersColumnLayout.nameLabelInset,
                ),
                Expanded(
                  child: Text('CUSTOMER NAME', style: _style()),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _MyCustomersColumnLayout.uid,
            child: Center(child: Text('UID', style: _style())),
          ),
          SizedBox(
            width: _MyCustomersColumnLayout.actions,
            child: Center(child: Text('ACTIONS', style: _style())),
          ),
          SizedBox(
            width: _MyCustomersColumnLayout.login,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('LOGIN', style: _style()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerRowCard extends StatelessWidget {
  const _CustomerRowCard({
    required this.item,
    required this.interactionLocked,
    required this.rowLoginLoading,
    required this.rowOrdersLoading,
    required this.onViewOrders,
    required this.onEdit,
    required this.onDelete,
    required this.onLogin,
  });

  final StoreCustomerItemDto item;
  final bool interactionLocked;
  final bool rowLoginLoading;
  final bool rowOrdersLoading;
  final VoidCallback onViewOrders;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLogin;

  static const Color _uidPillText = Color(0xFF2A2826);

  @override
  Widget build(BuildContext context) {
    final String secondary = _customerSecondaryLine(item);
    final String? avatarUrl = item.avatar?.trim();
    final bool hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Color.fromRGBO(0, 0, 0, 0.2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: interactionLocked ? null : onViewOrders,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _CustomerAvatar(
                                    hasAvatar: hasAvatar,
                                    avatarUrl: avatarUrl ?? '',
                                    name: item.name,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: ProMaxTokens.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          secondary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: ProMaxTokens.textSecondary
                                                .withValues(
                                              alpha: 0.92,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: _MyCustomersColumnLayout.uid,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: interactionLocked ? null : onViewOrders,
                            child: Center(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(207, 218, 242, 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: rowOrdersLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          '${item.id}',
                                          style: const TextStyle(
                                            color: _uidPillText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: _MyCustomersColumnLayout.actions,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: interactionLocked ? null : onEdit,
                        style: TextButton.styleFrom(
                          foregroundColor: ProMaxTokens.textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Edit'),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          color: ProMaxTokens.textSecondary.withValues(
                            alpha: 0.45,
                          ),
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: interactionLocked ? null : onDelete,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: _MyCustomersColumnLayout.login,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: interactionLocked ? null : onLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: ProMaxTokens.textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: rowLoginLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.38),
                        size: 22,
                      ),
                    ],
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

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({
    required this.hasAvatar,
    required this.avatarUrl,
    required this.name,
  });

  final bool hasAvatar;
  final String avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    const double size = _MyCustomersColumnLayout.avatar;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.28),
          child: hasAvatar
              ? Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _AvatarFallback(name: name),
                )
              : _AvatarFallback(name: name),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String letter = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: ProMaxTokens.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
