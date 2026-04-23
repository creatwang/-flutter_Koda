import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/draggable_scan_fab.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_scan_fab_flow.dart';

class GlobalProductScanFabWidget extends ConsumerStatefulWidget {
  const GlobalProductScanFabWidget({required this.bottomOffset, super.key});

  final double bottomOffset;

  @override
  ConsumerState<GlobalProductScanFabWidget> createState() =>
      _GlobalProductScanFabWidgetState();
}

class _GlobalProductScanFabWidgetState
    extends ConsumerState<GlobalProductScanFabWidget> {
  Future<void> _onScanQrTap() =>
      runProductQrScanFlow(ref: ref, context: context);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: DraggableScanFab(
          initialBottomOffset: widget.bottomOffset,
          onTap: _onScanQrTap,
        ),
      ),
    );
  }
}
