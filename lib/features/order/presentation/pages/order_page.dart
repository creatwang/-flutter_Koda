import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/order/controllers/order_providers.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class OrderPage extends ConsumerWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    return ordersState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(
        message: '订单加载失败: $error',
        onRetry: () => ref.read(ordersProvider.notifier).refresh(),
      ),
      data: (orders) {
        if (orders.isEmpty) return const AppEmptyView(message: '暂无订单');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final order = orders[index];
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('订单 #${order.id}'),
              subtitle: Text(
                '用户 ${order.userId} · 商品数量 ${order.totalQuantity} · ${order.date.toLocal()}',
              ),
            );
          },
        );
      },
    );
  }
}
