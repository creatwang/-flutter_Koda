import 'package:flutter/material.dart';

class ProductDetailQtyAdjustButton extends StatelessWidget {
  const ProductDetailQtyAdjustButton({
    super.key,
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.white38 : Colors.white,
        ),
      ),
    );
  }
}
