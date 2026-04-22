import 'package:flutter/material.dart';

class DraggableScanFab extends StatefulWidget {
  const DraggableScanFab({
    required this.onTap,
    this.initialBottomOffset = _fabMargin,
    super.key,
  });

  final VoidCallback onTap;
  final double initialBottomOffset;

  static const double _fabMargin = 20;

  @override
  State<DraggableScanFab> createState() => _DraggableScanFabState();
}

class _DraggableScanFabState extends State<DraggableScanFab> {
  static const double _fabSize = 56;
  static const double _fabMargin = DraggableScanFab._fabMargin;

  Offset? _fabOffset;
  bool _fabDragging = false;

  @override
  void didUpdateWidget(covariant DraggableScanFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBottomOffset != widget.initialBottomOffset) {
      // 配置变更后重置锚点，避免沿用历史拖拽坐标导致位置不更新。
      _fabOffset = null;
    }
  }

  Offset _defaultFabOffset(Size size) {
    final maxX = _maxFabX(size);
    final requestedTop = size.height - _fabSize - widget.initialBottomOffset;
    final defaultTop = requestedTop.clamp(_fabMargin, _maxFabY(size));
    return Offset(maxX, defaultTop);
  }

  double _maxFabX(Size size) {
    final maxX = size.width - _fabSize - _fabMargin;
    return maxX < _fabMargin ? _fabMargin : maxX;
  }

  double _maxFabY(Size size) {
    final maxY = size.height - _fabSize - _fabMargin;
    return maxY < _fabMargin ? _fabMargin : maxY;
  }

  Offset _clampFabOffset(Offset value, Size size) {
    return Offset(
      value.dx.clamp(_fabMargin, _maxFabX(size)),
      value.dy.clamp(_fabMargin, _maxFabY(size)),
    );
  }

  void _onFabDragUpdate(DragUpdateDetails details, Size canvasSize) {
    final current = _fabOffset ?? _defaultFabOffset(canvasSize);
    setState(() {
      _fabDragging = true;
      _fabOffset = _clampFabOffset(current + details.delta, canvasSize);
    });
  }

  void _onFabDragEnd(Size canvasSize) {
    final current = _clampFabOffset(_fabOffset ?? _defaultFabOffset(canvasSize), canvasSize);
    final dockLeft = current.dx + (_fabSize / 2) < (canvasSize.width / 2);
    final targetX = dockLeft ? _fabMargin : _maxFabX(canvasSize);
    setState(() {
      _fabDragging = false;
      _fabOffset = Offset(targetX, current.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final fabOffset = _clampFabOffset(_fabOffset ?? _defaultFabOffset(canvasSize), canvasSize);
        return Stack(
          children: [
            AnimatedPositioned(
              duration: _fabDragging ? Duration.zero : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              left: fabOffset.dx,
              top: fabOffset.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                onPanUpdate: (details) => _onFabDragUpdate(details, canvasSize),
                onPanEnd: (_) => _onFabDragEnd(canvasSize),
                child: FloatingActionButton.small(
                  heroTag: 'product_scan_qr_fab',
                  backgroundColor: Colors.black,
                  onPressed: widget.onTap,
                  child: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                ),
              )
            ),
          ],
        );
      },
    );
  }
}
