import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/auth/controllers/session_providers.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/adaptive_scaffold.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';
import 'package:groe_app_pad/shared/widgets/header_menu_button.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final productState = ref.watch(productByIdProvider(productId));
    final cartCount = ref.watch(
      cartControllerProvider.select(
        (value) => value.asData?.value.fold<int>(0, (sum, e) => sum + e.quantity) ?? 0,
      ),
    );

    return AdaptiveScaffold(
      title: l10n.appTitle,
      actions: [
        HeaderMenuButton(
          label: l10n.homeProducts,
          icon: Icons.storefront,
          selected: true,
          onTap: () => context.go(AppRoutes.homeWithTab('products')),
        ),
        HeaderMenuButton(
          label: l10n.homeCartWithCount(cartCount),
          icon: Icons.shopping_cart_outlined,
          selected: false,
          onTap: () => context.go(AppRoutes.homeWithTab('cart')),
        ),
        HeaderMenuButton(
          label: l10n.homeOrders,
          icon: Icons.receipt_long_outlined,
          selected: false,
          onTap: () => context.go(AppRoutes.homeWithTab('orders')),
        ),
        IconButton(
          tooltip: l10n.commonLogout,
          onPressed: () async {
            await ref.read(sessionControllerProvider.notifier).signOut();
            if (context.mounted) context.go(AppRoutes.login);
          },
          icon: const Icon(Icons.logout),
        ),
      ],
      body: productState.when(
        loading: () => const AppLoadingView(),
        error: (error, _) => AppErrorView(message: l10n.productDetailLoadFailed(error.toString())),
        data: (product) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 280,
                child: Image.network(
                  product.mainImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              ),
              const SizedBox(height: 16),
              Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '¥ ${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(product.categoryName, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 16),
              Text(product.id.toString()),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  ref.read(cartControllerProvider.notifier).addProduct(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.productAddedToCart(product.name))),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(l10n.addToCart),
              ),
            ],
          );
        },
      ),
    );
  }
}
