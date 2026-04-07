import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/order/models/order_create_item.dart';
import 'package:groe_app_pad/features/order/controllers/order_providers.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    return cartState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(message: '购物车加载失败: $error'),
      data: (items) {
        if (items.isEmpty) return const AppEmptyView(message: '购物车为空');
        final totalPrice = items.fold<double>(
          0,
          (sum, e) => sum + (e.product.price * e.quantity),
        );

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(item.product.title),
                    subtitle: Text('¥ ${item.product.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => ref
                              .read(cartControllerProvider.notifier)
                              .decrementProduct(item.product.id),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          onPressed: () =>
                              ref.read(cartControllerProvider.notifier).addProduct(item.product),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(cartControllerProvider.notifier)
                              .removeProduct(item.product.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '合计: ¥ ${totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final orderItems = items
                            .map((e) => OrderCreateItem(
                                  productId: e.product.id,
                                  quantity: e.quantity,
                                ))
                            .toList(growable: false);
                        final ok = await ref.read(ordersProvider.notifier).createOrder(
                              userId: 1,
                              items: orderItems,
                            );
                        if (!context.mounted) return;
                        if (ok) {
                          ref.read(cartControllerProvider.notifier).clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('下单成功，已加入订单列表')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('下单失败，请稍后重试')),
                          );
                        }
                      },
                      child: const Text('去结算'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
