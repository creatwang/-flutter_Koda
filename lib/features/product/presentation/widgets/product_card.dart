import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    required this.productItem,
    this.isCollected,
    this.onCollectChanged,
    super.key,
  });

  final ProductItem productItem;
  final bool? isCollected;
  final ValueChanged<bool>? onCollectChanged;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isCollected;

  @override
  void initState() {
    super.initState();
    _isCollected = widget.isCollected ?? widget.productItem.isCollect;
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldValue = oldWidget.isCollected ?? oldWidget.productItem.isCollect;
    final newValue = widget.isCollected ?? widget.productItem.isCollect;
    if (oldValue != newValue) {
      _isCollected = newValue;
    }
  }

  void _toggleCollected() {
    setState(() => _isCollected = !_isCollected);
    widget.onCollectChanged?.call(_isCollected);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withValues(alpha: 0.28),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(AppRoutes.productDetail(widget.productItem.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
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
                          widget.productItem.mainImage,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEW COLLECTION',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.productItem.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _toggleCollected,
                    icon: Icon(
                      _isCollected ? Icons.favorite : Icons.favorite_border,
                      color: _isCollected ? const Color(0xFFE74C3C) : Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
              Text(
                '¥${widget.productItem.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
