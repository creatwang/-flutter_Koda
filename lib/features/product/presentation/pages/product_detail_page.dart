import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/cart/presentation/providers/cart_controller.dart';
import 'package:groe_app_pad/features/product/controllers/product_providers.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';
import 'package:groe_app_pad/shared/widgets/adaptive_scaffold.dart';
import 'package:groe_app_pad/shared/widgets/app_error_view.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({required this.productId, super.key});

  final int productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int? _selectedProductId;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detailState = ref.watch(productDetailProvider(widget.productId));
    return AdaptiveScaffold(
      title: l10n.appTitle,
      automaticallyImplyLeading: false,
      body: SafeArea(
        child: detailState.when(
          loading: () => const AppLoadingView(),
          error: (error, _) => AppErrorView(
            message: l10n.productDetailLoadFailed(error.toString()),
            onRetry: () => ref.invalidate(productDetailProvider(widget.productId)),
          ),
          data: (detail) => _buildDetailContent(context, detail),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, ProductDetailDto detail) {
    final l10n = context.l10n;
    final variants = detail.product ?? const <Product>[];
    if (variants.isEmpty) {
      return AppErrorView(message: l10n.productDetailVariantsEmpty);
    }

    final fallbackId = detail.id ?? variants.first.id ?? widget.productId;
    final currentId = _selectedProductId ?? fallbackId;
    final selected = variants.firstWhereOrNull((e) => e.id == currentId) ?? variants.first;
    final selectedId = selected.id ?? fallbackId;

    final optionPathByPid = <int, String>{
      for (final item in detail.productSub ?? const <ProductSub>[])
        if (item.pid != null && item.sIndex != null) item.pid!: item.sIndex!,
    };
    if (optionPathByPid.isEmpty) {
      for (final item in variants) {
        final p = item.productSub?.firstOrNull;
        if (p?.pid != null && p?.sIndex != null) {
          optionPathByPid[p!.pid!] = p.sIndex!;
        }
      }
    }
    final optionPath = optionPathByPid[selectedId] ?? '';

    final images = <String>[
      ...(selected.subImages ?? const <String>[]).where((e) => e.trim().isNotEmpty),
      if ((selected.subImages ?? const <String>[]).isEmpty)
        ...(detail.subImages ?? const <String>[]).where((e) => e.trim().isNotEmpty),
      if ((selected.subImages ?? const <String>[]).isEmpty &&
          (detail.subImages ?? const <String>[]).isEmpty &&
          (selected.mainImage?.trim().isNotEmpty ?? false))
        selected.mainImage!,
    ];
    final imageIndex = images.isEmpty ? 0 : _selectedImageIndex.clamp(0, images.length - 1);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(l10n.productDetailBackToList),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: _cardDecoration(),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 78,
                              child: ListView.separated(
                                itemCount: images.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, index) {
                                  final selectedThumb = imageIndex == index;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedImageIndex = index),
                                    child: Container(
                                      height: 74,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedThumb
                                              ? Colors.white
                                              : Colors.white.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: Image.network(
                                          images[index],
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const ColoredBox(
                                            color: Color(0x22111111),
                                            child: Icon(Icons.broken_image, color: Colors.white70),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ColoredBox(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  child: images.isEmpty
                                      ? const Center(child: Icon(Icons.image_not_supported))
                                      : Image.network(
                                          images[imageIndex],
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(child: Icon(Icons.image_not_supported)),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 390,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: _cardDecoration(),
                        child: _buildInfoPanel(
                          context,
                          detail,
                          selected,
                          selectedId,
                          optionPath,
                          variants,
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
    );
  }

  Widget _buildInfoPanel(
    BuildContext context,
    ProductDetailDto detail,
    Product selected,
    int selectedId,
    String optionPath,
    List<Product> variants,
  )
  {
    final l10n = context.l10n;
    final title = selected.name ?? detail.name ?? '--';
    final category = (selected.categoryName ?? detail.categoryName ?? '').toUpperCase();
    final price = selected.price ?? detail.price ?? 0;
    final maxPrice = selected.maxPrice ?? detail.maxPrice ?? price;
    final specGroups = selected.specValue ?? const <SpecValue>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.isEmpty ? l10n.productDetailMasterpieceCollection : category,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 46,
            height: 1.05,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            if (maxPrice > price)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '€${maxPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    decoration: TextDecoration.lineThrough,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: variants.map((product) {
                          final pid = product.id;
                          final isSelected = pid != null && pid == selectedId;
                          final display = product.name ?? product.nameCn ?? '--';
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: pid == null
                                ? null
                                : () {
                                    setState(() {
                                      _selectedProductId = pid;
                                      _selectedImageIndex = 0;
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                display,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(growable: false),
                      ),
                    ],
                  ),
                ),
                ...specGroups
                    .where((group) => (group.options ?? const <Options>[]).isNotEmpty)
                    .map((group) {
                  final options = group.options ?? const <Options>[];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (group.name ?? '').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: options.map((option) {
                            final spec = option.spec ?? '';
                            final isSelected = spec.isNotEmpty && optionPath.contains(spec);
                            final display = option.name ?? option.nameCn ?? '--';
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                final pid = option.pid?.firstOrNull;
                                if (pid == null) return;
                                setState(() {
                                  _selectedProductId = pid;
                                  _selectedImageIndex = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  display,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(growable: false),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).addProduct(_toProductItem(selected));
              context.go(AppRoutes.homeWithTab('cart'));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(l10n.productDetailBuyNow),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).addProduct(_toProductItem(selected));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.productAddedToCart(title))),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(context.l10n.addToCart),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    );
  }

  ProductItem _toProductItem(Product product) {
    return ProductItem(
      id: product.id ?? widget.productId,
      categoryName: product.categoryName ?? '',
      categoryId: product.categoryId ?? 0,
      name: product.name ?? '',
      unit: product.unit ?? '',
      maxPrice: product.maxPrice ?? 0,
      price: product.price ?? 0,
      isHot: '${product.isHot ?? 0}',
      mainImage: product.mainImage ?? '',
      isCollect: product.isCollect ?? false,
    );
  }
}
