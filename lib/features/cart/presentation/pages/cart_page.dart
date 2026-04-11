import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/order/models/order_create_item.dart';
import 'package:groe_app_pad/features/order/controllers/order_providers.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cartState = ref.watch(cartControllerProvider);
    return cartState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(message: l10n.cartLoadFailed(error.toString())),
      data: (items) {
        if (items.isEmpty) return AppEmptyView(message: l10n.cartEmpty);
        final totalPrice = items.fold<double>(
          0,
          (sum, e) => sum + (e.productItem.price * e.quantity),
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
                    title: Text(item.productItem.name),
                    subtitle: Text('¥ ${item.productItem.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => ref
                              .read(cartControllerProvider.notifier)
                              .decrementProduct(item.productItem.id),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          onPressed: () =>
                              ref.read(cartControllerProvider.notifier).addProduct(item.productItem),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(cartControllerProvider.notifier)
                              .removeProduct(item.productItem.id),
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
                        l10n.cartTotal(totalPrice.toStringAsFixed(2)),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final orderItems = items
                            .map((e) => OrderCreateItem(
                                  productId: e.productItem.id,
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
                            SnackBar(content: Text(l10n.orderCreateSuccess)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.orderCreateFailed)),
                          );
                        }
                      },
                      child: Text(l10n.checkout),
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
