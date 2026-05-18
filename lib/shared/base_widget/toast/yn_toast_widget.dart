// YnToast 是一个自包含的顶部状态提示组件。
//
// 迁移到其他项目时仅需复制本文件，并在目标页面引入：
// `import 'yn_toast_widget.dart';`
//
// 依赖：
// - flutter/material.dart
// - flutter/scheduler.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum YnToastType { success, info, warning, error }

enum _YnToastPhase { idle, loading, success }

class YnToastShowOptions {
  const YnToastShowOptions({
    this.duration = const Duration(milliseconds: 2600),
    this.loadingDuration = const Duration(milliseconds: 1400),
    this.persist = false,
    this.mask = false,
  });

  final Duration duration;
  final Duration loadingDuration;
  final bool persist;
  final bool mask;
}

class YnToastDoneOptions {
  const YnToastDoneOptions({
    this.duration = const Duration(milliseconds: 2600),
    this.persist = false,
  });

  final Duration duration;
  final bool persist;
}

class YnToastController {
  _YnToastOverlayState? _state;
  _PendingDone? _pendingDone;
  bool _hasPendingHide = false;

  void done(
      YnToastType type, {
        String? message,
        YnToastDoneOptions options = const YnToastDoneOptions(),
      }) {
    final state = _state;
    if (state == null) {
      _pendingDone = _PendingDone(type, message, options);
      return;
    }
    state.finish(type, message: message, options: options);
  }

  void hide() {
    final state = _state;
    if (state == null) {
      _hasPendingHide = true;
      return;
    }
    state.hide();
  }

  void _attach(_YnToastOverlayState state) {
    _state = state;
    final pendingDone = _pendingDone;
    if (_hasPendingHide) {
      state.hide();
    } else if (pendingDone != null) {
      state.finish(
        pendingDone.type,
        message: pendingDone.message,
        options: pendingDone.options,
      );
    }
    _pendingDone = null;
    _hasPendingHide = false;
  }

  void _detach(_YnToastOverlayState state) {
    if (_state == state) _state = null;
  }
}

class _PendingDone {
  const _PendingDone(this.type, this.message, this.options);

  final YnToastType type;
  final String? message;
  final YnToastDoneOptions options;
}

class YnToast {
  const YnToast._();

  /// 当前由「同步快捷」API 展示的 Toast（success/error 等，无 loading 阶段）。
  static YnToastController? _activeSyncController;

  /// 新的同步 Toast 展示前，先收起上一次同步 Toast（与全局 SnackBar hide 同理）。
  static void _dismissActiveSyncToast() {
    final previous = _activeSyncController;
    if (previous == null) return;
    _activeSyncController = null;
    previous.hide();
  }

  static void _trackActiveSyncToast(YnToastController controller) {
    _activeSyncController = controller;
  }

  static void _releaseActiveSyncToast(YnToastController controller) {
    if (_activeSyncController == controller) {
      _activeSyncController = null;
    }
  }

  static YnToastController show(
      BuildContext context, {
        YnToastType type = YnToastType.success,
        String? message,
        YnToastShowOptions options = const YnToastShowOptions(),
      }) {
    return _insert(context, type: type, message: message, showOptions: options);
  }

  static YnToastController success(
      BuildContext context, {
        String? message,
        YnToastDoneOptions options = const YnToastDoneOptions(),
      }) {
    return _insertShortcut(
      context,
      type: YnToastType.success,
      message: message,
      options: options,
    );
  }

  static YnToastController info(
      BuildContext context, {
        String? message,
        YnToastDoneOptions options = const YnToastDoneOptions(),
      }) {
    return _insertShortcut(
      context,
      type: YnToastType.info,
      message: message,
      options: options,
    );
  }

  static YnToastController warning(
      BuildContext context, {
        String? message,
        YnToastDoneOptions options = const YnToastDoneOptions(),
      }) {
    return _insertShortcut(
      context,
      type: YnToastType.warning,
      message: message,
      options: options,
    );
  }

  static YnToastController error(
      BuildContext context, {
        String? message,
        YnToastDoneOptions options = const YnToastDoneOptions(),
      }) {
    return _insertShortcut(
      context,
      type: YnToastType.error,
      message: message,
      options: options,
    );
  }

  static Future<T> task<T>(
      BuildContext context,
      Future<T> Function(YnToastController controller) task, {
        YnToastType type = YnToastType.success,
        bool mask = false,
      }) async {
    final controller = show(
      context,
      type: type,
      options: YnToastShowOptions(
        loadingDuration: const Duration(days: 1),
        mask: mask,
        persist: true,
      ),
    );
    try {
      return await task(controller);
    } catch (error) {
      controller.done(
        YnToastType.error,
        message: error is Error ? error.toString() : 'error!',
      );
      rethrow;
    }
  }

  static YnToastController _insertShortcut(
      BuildContext context, {
        required YnToastType type,
        String? message,
        required YnToastDoneOptions options,
      }) {
    return _insert(
      context,
      type: type,
      message: message,
      showOptions: YnToastShowOptions(
        duration: options.duration,
        loadingDuration: Duration.zero,
        persist: options.persist,
      ),
      replaceActiveSync: true,
    );
  }

  /// 在指定 [overlay] 上展示（用于 [MaterialApp.builder] 之上的全局 Toast 层）。
  static YnToastController showOnOverlay(
      OverlayState overlay, {
        required YnToastType type,
        String? message,
        YnToastDoneOptions options = const YnToastDoneOptions(),
      }) {
    return _insertOnOverlay(
      overlay,
      type: type,
      message: message,
      showOptions: YnToastShowOptions(
        duration: options.duration,
        loadingDuration: Duration.zero,
        persist: options.persist,
      ),
      replaceActiveSync: true,
    );
  }

  /// 在 [overlay] 上展示持久 loading，由调用方 [YnToastController.done] 结束。
  static YnToastController showLoadingOnOverlay(
      OverlayState overlay, {
        YnToastType type = YnToastType.info,
        String? message,
        bool mask = false,
      }) {
    return _insertOnOverlay(
      overlay,
      type: type,
      message: message,
      showOptions: YnToastShowOptions(
        loadingDuration: const Duration(days: 1),
        persist: true,
        mask: mask,
      ),
    );
  }

  static YnToastController _insert(
      BuildContext context, {
        required YnToastType type,
        String? message,
        required YnToastShowOptions showOptions,
        bool replaceActiveSync = false,
      }) {
    return _insertOnOverlay(
      Overlay.of(context, rootOverlay: true),
      type: type,
      message: message,
      showOptions: showOptions,
      replaceActiveSync: replaceActiveSync,
    );
  }

  static YnToastController _insertOnOverlay(
      OverlayState overlay, {
        required YnToastType type,
        String? message,
        required YnToastShowOptions showOptions,
        bool replaceActiveSync = false,
      }) {
    if (replaceActiveSync) {
      _dismissActiveSyncToast();
    }

    final controller = YnToastController();
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _YnToastOverlay(
        controller: controller,
        entry: entry,
        initialType: type,
        initialMessage: message,
        showOptions: showOptions,
      ),
    );
    overlay.insert(entry);
    if (replaceActiveSync) {
      _trackActiveSyncToast(controller);
    }
    return controller;
  }
}

class _YnToastOverlay extends StatefulWidget {
  const _YnToastOverlay({
    required this.controller,
    required this.entry,
    required this.initialType,
    required this.showOptions,
    this.initialMessage,
  });

  final YnToastController controller;
  final OverlayEntry entry;
  final YnToastType initialType;
  final String? initialMessage;
  final YnToastShowOptions showOptions;

  @override
  State<_YnToastOverlay> createState() => _YnToastOverlayState();
}

class _YnToastOverlayState extends State<_YnToastOverlay>
    with SingleTickerProviderStateMixin {
  static const _height = 36.0;
  static const _ballSize = 32.0;
  static const _top = 26.0;
  static const _messagePadding = EdgeInsets.only(left: 6, right: 14);
  static const _spinRampDuration = Duration(milliseconds: 1400);

  late final Ticker _spinTicker;
  late final ValueNotifier<_SpinSnapshot> _spinSnapshotNotifier;
  Timer? _loadingTimer;
  Timer? _hideTimer;
  Timer? _enterTimer;
  _YnToastPhase _phase = _YnToastPhase.idle;
  YnToastType _type = YnToastType.success;
  String _message = '';
  bool _hasMessage = true;
  bool _loadingMask = false;
  bool _isRemoved = false;
  Duration _lastSpinElapsed = Duration.zero;
  Duration? _spinEpochElapsed;
  _ToastSize? _cachedSize;
  String _cachedMeasureMessage = '';
  bool _cachedMeasureHasMessage = false;
  double _cachedMeasureMaxWidth = -1;
  double _swipeY = 0;
  double _swipeStartY = 0;

  @override
  void initState() {
    super.initState();
    _spinTicker = createTicker(_onSpinTick);
    _spinSnapshotNotifier = ValueNotifier(
      const _SpinSnapshot(angleRad: 0, ringOpacity: 0.92),
    );
    _startLoading();
    widget.controller._attach(this);
  }

  @override
  void dispose() {
    _clearTimers();
    _spinTicker.dispose();
    _spinSnapshotNotifier.dispose();
    widget.controller._detach(this);
    super.dispose();
  }

  void _onSpinTick(Duration elapsed) {
    if (!mounted || _phase != _YnToastPhase.loading) return;
    final epoch = _spinEpochElapsed ?? elapsed;
    _spinEpochElapsed ??= elapsed;
    final relativeElapsed = elapsed - epoch;
    final dt = (relativeElapsed - _lastSpinElapsed).inMicroseconds / 1000000;
    _lastSpinElapsed = relativeElapsed;
    if (dt <= 0) return;
    final totalMs = _spinRampDuration.inMilliseconds;
    final progress = totalMs <= 0
        ? 1.0
        : (relativeElapsed.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final smooth = math.pow(progress, 3).toDouble();
    final speedDegPerSecond = 420 + smooth * 4300;
    final spinAngleDeg =
        (_spinSnapshotNotifier.value.angleRad * 180 / math.pi +
            speedDegPerSecond * dt) %
            360;
    final visualSoftness = (progress * 1.35).clamp(0.0, 1.0);
    _spinSnapshotNotifier.value = _SpinSnapshot(
      angleRad: spinAngleDeg * (math.pi / 180),
      ringOpacity: 0.92 - visualSoftness * 0.22,
    );
  }

  void _startSpin() {
    _spinEpochElapsed = null;
    _lastSpinElapsed = Duration.zero;
    _spinSnapshotNotifier.value = const _SpinSnapshot(
      angleRad: 0,
      ringOpacity: 0.92,
    );
    _spinTicker.start();
  }

  void _stopSpin() {
    _spinTicker.stop();
  }

  void finish(
      YnToastType type, {
        String? message,
        YnToastDoneOptions options = const YnToastDoneOptions(),
      }) {
    if (!mounted || _isRemoved) return;
    _clearTimers();
    _stopSpin();
    setState(() {
      _type = type;
      _message = _resolveMessage(type, message);
      _hasMessage = _message.trim().isNotEmpty;
      _loadingMask = false;
      _phase = _YnToastPhase.success;
      _swipeY = 0;
    });
    if (options.persist) return;
    _hideTimer = Timer(options.duration, hide);
  }

  void hide() {
    if (!mounted || _isRemoved) return;
    _clearTimers();
    _stopSpin();
    setState(() {
      _loadingMask = false;
      _phase = _YnToastPhase.idle;
      _swipeY = 0;
    });
    _hideTimer = Timer(const Duration(milliseconds: 280), _removeEntry);
  }

  void _startLoading() {
    _type = widget.initialType;
    _message = _resolveMessage(widget.initialType, widget.initialMessage);
    _hasMessage = _message.trim().isNotEmpty;
    _loadingMask = widget.showOptions.mask;
    _enterTimer = Timer(Duration.zero, () {
      if (!mounted || _isRemoved) return;
      setState(() {
        _phase = _YnToastPhase.loading;
      });
      _startSpin();
      _loadingTimer = Timer(widget.showOptions.loadingDuration, () {
        finish(
          widget.initialType,
          message: widget.initialMessage,
          options: YnToastDoneOptions(
            duration: widget.showOptions.duration,
            persist: widget.showOptions.persist,
          ),
        );
      });
    });
  }

  void _clearTimers() {
    _loadingTimer?.cancel();
    _hideTimer?.cancel();
    _enterTimer?.cancel();
    _loadingTimer = null;
    _hideTimer = null;
    _enterTimer = null;
  }

  void _removeEntry() {
    if (_isRemoved) return;
    _isRemoved = true;
    YnToast._releaseActiveSyncToast(widget.controller);
    widget.entry.remove();
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    _swipeStartY = details.globalPosition.dy;
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_phase == _YnToastPhase.idle) return;
    final deltaY = details.globalPosition.dy - _swipeStartY;
    setState(() {
      _swipeY = math.min(0, deltaY);
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_swipeY < -32) {
      hide();
      return;
    }
    setState(() {
      _swipeY = 0;
    });
  }

  String _resolveMessage(YnToastType type, String? message) {
    if (message != null) return message;
    return switch (type) {
      YnToastType.success => 'success!',
      YnToastType.info => 'info!',
      YnToastType.warning => 'warning!',
      YnToastType.error => 'error!',
    };
  }

  _ToastSize _measureToastSize(BuildContext context, double maxWidth) {
    final upper = _message.toUpperCase();
    if (_cachedSize != null &&
        _cachedMeasureMessage == upper &&
        _cachedMeasureHasMessage == _hasMessage &&
        _cachedMeasureMaxWidth == maxWidth) {
      return _cachedSize!;
    }
    final measured = _ToastSizeCalculator.measure(
      context: context,
      message: upper,
      hasMessage: _hasMessage,
      maxWidth: maxWidth,
      height: _height,
      padding: _messagePadding,
    );
    _cachedSize = measured;
    _cachedMeasureMessage = upper;
    _cachedMeasureHasMessage = _hasMessage;
    _cachedMeasureMaxWidth = maxWidth;
    return measured;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: _phase == _YnToastPhase.idle,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              if (_loadingMask && _phase == _YnToastPhase.loading)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _withAlpha(const Color(0xFF20231D), 0.18),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: _top),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth * 0.9;
                      final size = _measureToastSize(context, maxWidth);
                      return Transform.translate(
                        offset: Offset(0, _swipeY),
                        child: _ToastPill(
                          phase: _phase,
                          type: _type,
                          message: _message,
                          hasMessage: _hasMessage,
                          width: size.width,
                          height: size.height,
                          maxMessageWidth: size.messageWidth,
                          shouldWrapMessage: size.shouldWrap,
                          spinSnapshotListenable: _spinSnapshotNotifier,
                          onVerticalDragStart: _handleVerticalDragStart,
                          onVerticalDragUpdate: _handleVerticalDragUpdate,
                          onVerticalDragEnd: _handleVerticalDragEnd,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastPill extends StatelessWidget {
  const _ToastPill({
    required this.phase,
    required this.type,
    required this.message,
    required this.hasMessage,
    required this.width,
    required this.height,
    required this.maxMessageWidth,
    required this.shouldWrapMessage,
    required this.spinSnapshotListenable,
    required this.onVerticalDragStart,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final _YnToastPhase phase;
  final YnToastType type;
  final String message;
  final bool hasMessage;
  final double width;
  final double height;
  final double maxMessageWidth;
  final bool shouldWrapMessage;
  final ValueListenable<_SpinSnapshot> spinSnapshotListenable;
  final GestureDragStartCallback onVerticalDragStart;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    final isVisible = phase != _YnToastPhase.idle;
    final isSuccess = phase == _YnToastPhase.success;
    final showMessage = hasMessage && isSuccess;
    final targetWidth = isSuccess ? width : _YnToastOverlayState._height;
    final targetHeight = isSuccess ? height : _YnToastOverlayState._height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isVisible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          offset: isVisible ? Offset.zero : const Offset(0, -0.333),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            scale: isVisible ? 1 : 0.92,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 620),
              curve: Curves.easeOutCubic,
              width: targetWidth,
              height: targetHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _withAlpha(const Color(0xFFF6F1E6), 0.92),
                borderRadius: BorderRadius.circular(
                  targetHeight > _YnToastOverlayState._height ? 18 : 999,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _withAlpha(const Color(0xFF3E372A), 0.14),
                    blurRadius: 45,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: _withAlpha(const Color(0xFF3E372A), 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: targetHeight > _YnToastOverlayState._height
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _YnToastOverlayState._height,
                    height: targetHeight,
                    child: Center(
                      child: _ToastBall(
                        type: type,
                        phase: phase,
                        spinSnapshotListenable: spinSnapshotListenable,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 620),
                    curve: Curves.easeOutCubic,
                    width: isSuccess ? maxMessageWidth : 0,
                    child: Padding(
                      padding: _YnToastOverlayState._messagePadding,
                      child: Opacity(
                        opacity: showMessage ? 1 : 0,
                        child: Text(
                          message,
                          softWrap: shouldWrapMessage,
                          maxLines: shouldWrapMessage ? null : 1,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            color: Color(0xFF20231D),
                            fontSize: 12.8,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastBall extends StatelessWidget {
  const _ToastBall({
    required this.type,
    required this.phase,
    required this.spinSnapshotListenable,
  });

  final YnToastType type;
  final _YnToastPhase phase;
  final ValueListenable<_SpinSnapshot> spinSnapshotListenable;

  @override
  Widget build(BuildContext context) {
    final isLoading = phase == _YnToastPhase.loading;
    final isSuccess = phase == _YnToastPhase.success;

    return SizedBox.square(
      dimension: _YnToastOverlayState._ballSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            opacity: isLoading ? 1 : 0,
            child: ValueListenableBuilder<_SpinSnapshot>(
              valueListenable: spinSnapshotListenable,
              builder: (context, spin, child) {
                return CustomPaint(
                  size: const Size(28, 28),
                  painter: _ToastRingPainter(
                    spinAngleRad: spin.angleRad,
                    ringOpacity: spin.ringOpacity,
                  ),
                );
              },
            ),
          ),
          AnimatedScale(
            duration: const Duration(milliseconds: 580),
            curve: Curves.easeOutCubic,
            scale: isSuccess ? 1 : 0.35,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSuccess ? 1 : 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _toastColor(type),
                ),
                child: SizedBox.square(dimension: isSuccess ? 28 : 8),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            opacity: isSuccess ? 1 : 0,
            child: _ToastGlyph(type: type, isSuccess: isSuccess),
          ),
        ],
      ),
    );
  }
}

class _ToastGlyph extends StatelessWidget {
  const _ToastGlyph({required this.type, required this.isSuccess});

  static const _ease = Cubic(0.22, 1, 0.36, 1);
  final YnToastType type;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isSuccess ? 1 : 0),
      duration: const Duration(milliseconds: 680),
      curve: Curves.linear,
      builder: (context, t, child) {
        final appearT = ((t - 0.32) / 0.68).clamp(0.0, 1.0);
        final drawT = ((t - 0.26) / 0.74).clamp(0.0, 1.0);
        final appear = _ease.transform(appearT);
        final draw = _ease.transform(drawT);
        final rotation = (-12 * (1 - appear)) * (math.pi / 180);
        return Opacity(
          opacity: appear,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: 0.5 + appear * 0.5,
              child: SizedBox.square(
                dimension: 16,
                child: CustomPaint(
                  painter: _ToastGlyphPainter(type: type, progress: draw),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToastGlyphPainter extends CustomPainter {
  const _ToastGlyphPainter({required this.type, required this.progress});

  final YnToastType type;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFFF3EDDF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _toastGlyphPath(type, size);
    final clampedProgress = progress.clamp(0.0, 1.0);
    for (final metric in path.computeMetrics()) {
      final drawLength = metric.length * clampedProgress;
      if (drawLength <= 0) continue;
      canvas.drawPath(metric.extractPath(0, drawLength), strokePaint);
    }

    final dot = _toastGlyphDotLayout(type, size);
    if (dot == null) return;
    final dotReveal = ((clampedProgress - 0.5) / 0.5).clamp(0.0, 1.0);
    if (dotReveal <= 0) return;
    canvas.drawCircle(
      dot.center,
      dot.radius * dotReveal,
      Paint()
        ..color = const Color(0xFFF3EDDF)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ToastGlyphPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.progress != progress;
  }
}

Path _toastGlyphPath(YnToastType type, Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w * 0.5;
  final path = Path();
  switch (type) {
    case YnToastType.success:
      path
        ..moveTo(w * 0.22, h * 0.56)
        ..lineTo(w * 0.43, h * 0.76)
        ..lineTo(w * 0.8, h * 0.28);
    case YnToastType.info:
      path
        ..moveTo(cx, h * 0.36)
        ..lineTo(cx, h * 0.74);
    case YnToastType.warning:
    case YnToastType.error:
      path
        ..moveTo(cx, h * 0.22)
        ..lineTo(cx, h * 0.48);
  }
  return path;
}

class _ToastGlyphDotLayout {
  const _ToastGlyphDotLayout({required this.center, required this.radius});

  final Offset center;
  final double radius;
}

_ToastGlyphDotLayout? _toastGlyphDotLayout(YnToastType type, Size size) {
  final cx = size.width * 0.5;
  final h = size.height;
  return switch (type) {
    YnToastType.info => _ToastGlyphDotLayout(
      center: Offset(cx, h * 0.26),
      radius: h * 0.09,
    ),
    YnToastType.warning || YnToastType.error => _ToastGlyphDotLayout(
      center: Offset(cx, h * 0.80),
      radius: h * 0.10,
    ),
    _ => null,
  };
}

class _ToastRingPainter extends CustomPainter {
  const _ToastRingPainter({
    required this.spinAngleRad,
    required this.ringOpacity,
  });

  final double spinAngleRad;
  final double ringOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 2;
    const dashSweep = math.pi * 0.3;
    final basePrimary = -math.pi / 2 + math.pi * 2 * 0.08;
    final baseSecondary = -math.pi / 2 + math.pi * 2 * 0.58;
    final trackPaint = Paint()
      ..color = _withAlpha(const Color(0xFF20231D), 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final arcPaint = Paint()
      ..color = _withAlpha(const Color(0xFF20231D), ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.35;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      rect,
      basePrimary + spinAngleRad,
      dashSweep,
      false,
      arcPaint,
    );
    canvas.drawArc(
      rect,
      baseSecondary - spinAngleRad,
      dashSweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ToastRingPainter oldDelegate) {
    return oldDelegate.spinAngleRad != spinAngleRad ||
        oldDelegate.ringOpacity != ringOpacity;
  }
}

class _SpinSnapshot {
  const _SpinSnapshot({required this.angleRad, required this.ringOpacity});

  final double angleRad;
  final double ringOpacity;
}

class _ToastSize {
  const _ToastSize({
    required this.width,
    required this.height,
    required this.messageWidth,
    required this.shouldWrap,
  });

  final double width;
  final double height;
  final double messageWidth;
  final bool shouldWrap;
}

class _ToastSizeCalculator {
  const _ToastSizeCalculator._();

  static _ToastSize measure({
    required BuildContext context,
    required String message,
    required bool hasMessage,
    required double maxWidth,
    required double height,
    required EdgeInsets padding,
  }) {
    if (!hasMessage) {
      return _ToastSize(
        width: height,
        height: height,
        messageWidth: 0,
        shouldWrap: false,
      );
    }

    const textStyle = TextStyle(
      fontSize: 12.8,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: 1.8,
    );
    final maxMessageWidth = math.max(0.0, maxWidth - height);
    final naturalWidth = _measureWidth(
      context: context,
      message: message,
      style: textStyle,
    );
    final messageWidth = math.min(
      maxMessageWidth,
      naturalWidth + padding.horizontal,
    );
    final contentWidth = height + messageWidth;
    final shouldWrap = contentWidth >= maxWidth;
    final textHeight = _measureHeight(
      context: context,
      message: message,
      style: textStyle,
      maxWidth: math.max(0.0, messageWidth - padding.horizontal),
    );
    final wrappedHeight = textHeight + padding.vertical;

    return _ToastSize(
      width: math.min(maxWidth, contentWidth),
      height: shouldWrap ? math.max(height, wrappedHeight) : height,
      messageWidth: messageWidth,
      shouldWrap: shouldWrap,
    );
  }

  static double _measureWidth({
    required BuildContext context,
    required String message,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: message, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  static double _measureHeight({
    required BuildContext context,
    required String message,
    required TextStyle style,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: message, style: style),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxWidth);
    return painter.height;
  }
}

Color _toastColor(YnToastType type) {
  return switch (type) {
    YnToastType.success => const Color(0xFF667A48),
    YnToastType.info => const Color(0xFF5F6F86),
    YnToastType.warning => const Color(0xFFB87D55),
    YnToastType.error => const Color(0xFF9A4F43),
  };
}

Color _withAlpha(Color color, double opacity) {
  final alpha = (opacity.clamp(0.0, 1.0) * 255).round();
  return color.withAlpha(alpha);
}
