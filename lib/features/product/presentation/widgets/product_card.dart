import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({required this.productItem, super.key});

  final ProductItem productItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.productDetail(productItem.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Image.network(
                    productItem.mainImage,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                productItem.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '¥ ${productItem.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    ref.read(cartControllerProvider.notifier).addProduct(productItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.productAddedToCart(productItem.name))),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(l10n.addToCart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
