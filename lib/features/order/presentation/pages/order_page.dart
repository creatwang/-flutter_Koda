import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/order/controllers/order_providers.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/app_empty_view.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class OrderPage extends ConsumerWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ordersState = ref.watch(ordersProvider);
    return ordersState.when(
      loading: () => const AppLoadingView(),
      error: (error, _) => AppErrorView(
        message: l10n.orderLoadFailed(error.toString()),
        onRetry: () => ref.read(ordersProvider.notifier).refresh(),
      ),
      data: (orders) {
        if (orders.isEmpty) return AppEmptyView(message: l10n.orderEmpty);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final order = orders[index];
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(l10n.orderTitleWithId(order.id)),
              subtitle: Text(
                l10n.orderSubtitle(
                  order.userId,
                  order.totalQuantity,
                  order.date.toLocal().toString(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
