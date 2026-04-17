import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:groe_app_pad/theme/pro_max_tokens.dart';

class ProMaxGlassCardWidget extends StatelessWidget {
  const ProMaxGlassCardWidget({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(ProMaxTokens.space4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(ProMaxTokens.radiusCard);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ProMaxTokens.shimmerStart,
                ProMaxTokens.cardBackground,
                ProMaxTokens.shimmerEnd,
              ],
            ),
            border: Border.all(color: ProMaxTokens.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A000000),
                blurRadius: 20,
                spreadRadius: 1,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
