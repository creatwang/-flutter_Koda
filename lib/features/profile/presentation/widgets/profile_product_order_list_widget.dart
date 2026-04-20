import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/profile/controllers/profile_order_providers.dart';
import 'package:groe_app_pad/features/profile/models/product_order_list_dto.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

/// 订单中心「我的 / 客户」共用的商品订单列表（与 Order Center Customer 列表一致）。
class ProfileProductOrderListWidget extends StatelessWidget {
  const ProfileProductOrderListWidget({
    required this.asyncState,
    required this.onRefresh,
    required this.onLoadMore,
    required this.showUserInfo,
    super.key,
  });

  final AsyncValue<ProfileOrderListState> asyncState;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final bool showUserInfo;

  @override
  Widget build(BuildContext context) {
    return asyncState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => _OrderErrorView(
        message: error.toString(),
        onRetry: onRefresh,
      ),
      data: (data) {
        if (data.items.isEmpty) {
          return const AppEmptyView(
            message: 'No orders yet',
            width: 120,
            height: 120,
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >
                  notification.metrics.maxScrollExtent - 320) {
                onLoadMore();
              }
              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemBuilder: (_, index) {
                if (index >= data.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final item = data.items[index];
                return _OrderCard(
                  item: item,
                  showUserInfo: showUserInfo,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.item,
    required this.showUserInfo,
  });

  final OrderItemDto item;
  final bool showUserInfo;

  @override
  Widget build(BuildContext context) {
    final isPiSuccess = item.piStatus == 1;
    final piColor = isPiSuccess ? const Color(0xFF6CE596) : const Color(
      0xFFFF8C92,
    );
    final piText = isPiSuccess ? 'Successful' : 'Fail';
    final erpText = item.status == 1 ? 'Send to ERP' : 'Not sent to ERP';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showUserInfo && item.user != null) ...[
              Text(
                item.user?.name ?? item.user?.username ?? '--',
                style: const TextStyle(
                  color: ProMaxTokens.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 14, right: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OrderNo', style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500
                        ),),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          item.orderNo ?? '--',
                          style: const TextStyle(
                            color: ProMaxTokens.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Time: ${item.createdAt ?? '--'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          erpText,
                          style: const TextStyle(
                            color: Color(0xFF84CCFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: piColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              piText,
                              style: TextStyle(
                                color: piColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...item.product.map(
              (department) => _DepartmentBlock(department: department),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentBlock extends StatelessWidget {
  const _DepartmentBlock({required this.department});

  final OrderDepartmentDto department;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2)
      ),
      margin: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        visualDensity: VisualDensity(vertical: -2),
        shape: const Border(top: BorderSide(color: Color.fromRGBO(130, 130, 130, 1), )),
        initiallyExpanded: true,
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white60,
        tilePadding: const EdgeInsets.symmetric(horizontal: 30),
        title:Row( // 使用 Row 配合 MainAxisSize.min 让内容从左对齐并收缩
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open, size: 18,),
            SizedBox(
              width: 4,
            ),
            Text(
              department.name ?? 'Unknown Department',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        children: department.list
            .map((space) => _SpaceBlock(space: space))
            .toList(growable: false),
      ),
    );
  }
}

class _SpaceBlock extends StatelessWidget {
  const _SpaceBlock({required this.space});

  final OrderSpaceDto space;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: ListTileTheme(
        // 核心调整代码：
        horizontalTitleGap: 8,    // 1. 设置图标与文字之间的像素间距
        minLeadingWidth: 0,      // 2. 去掉 leading 图标的最小宽度限制（默认是 40）
        child: ExpansionTile(
          visualDensity: VisualDensity(vertical: -4),
          initiallyExpanded: true,
          // 1. 将箭头图标放在最前面
          leading: const Icon(Icons.expand_more, size: 20),
          // 2. 隐藏右侧默认的箭头
          trailing: const SizedBox.shrink(),
          shape: const Border(top: BorderSide(color: Color.fromRGBO(130, 130, 130, 1), )),
          iconColor: Colors.white70,
          tilePadding: EdgeInsets.symmetric(horizontal: 30),
          childrenPadding: EdgeInsets.only(left: 48),
          collapsedIconColor: Colors.white60,
          title: Row( // 使用 Row 配合 MainAxisSize.min 让内容从左对齐并收缩
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24, // 示例：给文字加个微弱背景
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                space.name ?? 'default',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
          children: [
            // 产品信息header 需要可以放出来
            // const _ProductTableHeader(),
            ...space.list.map((line) => _ProductLineTile(line: line)),
          ],
        ),
      ),
    );
  }
}

class _ProductLineTile extends StatelessWidget {
  const _ProductLineTile({required this.line});

  final OrderProductLineDto line;

  @override
  Widget build(BuildContext context) {
    final quantityText = '${line.quantity ?? 0}${line.unit ?? ''}';
    final priceText = '\$${line.totalPrice ?? line.price ?? '--'}';
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: line.mainImage == null || line.mainImage!.isEmpty
                        ? const ColoredBox(
                            color: Colors.black26,
                            child: Icon(Icons.image_not_supported_outlined),
                          )
                        : Image.network(
                            line.mainImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const ColoredBox(
                                color: Colors.black26,
                                child: Icon(Icons.broken_image_outlined),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.name ?? '--',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProMaxTokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        line.subName ?? '--',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'x$quantityText',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ProMaxTokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              priceText,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: ProMaxTokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderErrorView extends StatelessWidget {
  const _OrderErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText.rich(
              TextSpan(
                text: message,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
