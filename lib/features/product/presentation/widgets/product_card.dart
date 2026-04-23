import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/features/product/models/product_item.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.productItem,
    required this.isCollected,
    this.isCollectSubmitting = false,
    this.isAddToCartSubmitting = false,
    this.onCollectTap,
    this.onAddToCartTap,
    this.onBeforeNavigateToDetail,
    super.key,
  });

  final ProductItem productItem;
  final bool isCollected;
  final bool isCollectSubmitting;
  final bool isAddToCartSubmitting;
  final VoidCallback? onCollectTap;
  final VoidCallback? onAddToCartTap;

  /// 进入详情前回调（用于中断列表中的加购加载流程）。
  final VoidCallback? onBeforeNavigateToDetail;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withValues(alpha: 0.28),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          onBeforeNavigateToDetail?.call();
          context.push(AppRoutes.productDetail(productItem.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          productItem.mainImage,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    if (productItem.showsNewCollectionTag)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NEW COLLECTION',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 8.5,
                                  letterSpacing: 0.4,
                                ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isCollectSubmitting ? null : onCollectTap,
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.26),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Center(
                              child: isCollectSubmitting
                                  ? const SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      isCollected
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isCollected
                                          ? const Color(0xFFE74C3C)
                                          : Colors.white.withValues(
                                              alpha: 0.88,
                                            ),
                                      size: 10,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                productItem.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${productItem.price.toStringAsFixed(1)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _CartActionButton(
                    onTap: isAddToCartSubmitting || productItem.price <= 0
                        ? null
                        : onAddToCartTap,
                    isLoading: isAddToCartSubmitting,
                    compact: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartActionButton extends StatefulWidget {
  const _CartActionButton({
    required this.onTap,
    this.isLoading = false,
    this.compact = false,
  });

  final VoidCallback? onTap;
  final bool isLoading;
  final bool compact;

  @override
  State<_CartActionButton> createState() => _CartActionButtonState();
}

class _CartActionButtonState extends State<_CartActionButton> {
  double _scale = 1;

  void _onTapDown(TapDownDetails _) {
    if (widget.isLoading) return;
    setState(() => _scale = 0.92);
  }

  void _onTapCancel() => setState(() => _scale = 1);

  void _onTap() {
    if (widget.isLoading) return;
    setState(() => _scale = 1);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.isLoading;
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy || widget.onTap == null ? null : _onTap,
          onTapDown: busy || widget.onTap == null ? null : _onTapDown,
          onTapCancel: busy || widget.onTap == null ? null : _onTapCancel,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF0E213A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 12,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
