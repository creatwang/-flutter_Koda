// YnToast 是一个自包含的顶部状态提示组件。
//
// 迁移到其他项目时仅需复制本文件，并在目标页面引入：
// `import 'yn_toast_widget.dart';`
//
// 依赖：flutter/material.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum YnToastType { success, info, warning, error }

enum _YnToastPhase { idle, loading, success, exiting }

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

  void hide({bool quick = false}) {
    final state = _state;
    if (state == null) {
      _hasPendingHide = true;
      return;
    }
    state.hide(quick: quick);
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
    previous.hide(quick: true);
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
  static const _exitDuration = Duration(milliseconds: 320);
  static const _quickExitDuration = Duration(milliseconds: 180);

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
  bool _isQuickExit = false;

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

  void hide({bool quick = false}) {
    if (!mounted || _isRemoved) return;
    if (_phase == _YnToastPhase.exiting) return;
    _clearTimers();
    _stopSpin();
    _isQuickExit = quick;
    final dismissDuration = quick ? _quickExitDuration : _exitDuration;
    setState(() {
      _loadingMask = false;
      _phase = _YnToastPhase.exiting;
      _swipeY = 0;
    });
    _hideTimer = Timer(dismissDuration, _removeEntry);
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
    if (_phase != _YnToastPhase.loading && _phase != _YnToastPhase.success) {
      return;
    }
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
        ignoring:
            _phase == _YnToastPhase.idle || _phase == _YnToastPhase.exiting,
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
                          dismissDuration: _isQuickExit
                              ? _quickExitDuration
                              : _exitDuration,
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
    required this.dismissDuration,
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
  final Duration dismissDuration;
  final ValueListenable<_SpinSnapshot> spinSnapshotListenable;
  final GestureDragStartCallback onVerticalDragStart;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    final isExiting = phase == _YnToastPhase.exiting;
    final isActive =
        phase == _YnToastPhase.loading || phase == _YnToastPhase.success;
    final isExpanded =
        phase == _YnToastPhase.success || phase == _YnToastPhase.exiting;
    final showMessage = hasMessage && isExpanded;
    final targetWidth =
        isExpanded ? width : _YnToastOverlayState._height;
    final targetHeight =
        isExpanded ? height : _YnToastOverlayState._height;
    final exitDuration = dismissDuration;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: AnimatedOpacity(
        duration: isExiting ? exitDuration : const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        opacity: isActive ? 1 : 0,
        child: AnimatedSlide(
          duration: isExiting ? exitDuration : const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          offset: isExiting
              ? const Offset(0, -0.12)
              : (isActive ? Offset.zero : const Offset(0, -0.333)),
          child: AnimatedScale(
            duration:
                isExiting ? exitDuration : const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            scale: isExiting ? 0.94 : (isActive ? 1 : 0.92),
            child: AnimatedContainer(
              duration: isExiting
                  ? Duration.zero
                  : const Duration(milliseconds: 620),
              curve: Curves.easeOutCubic,
              width: targetWidth,
              height: targetHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _withAlpha(const Color(0xFFF6F1E6), 0.92),
                borderRadius: BorderRadius.circular(
                  targetHeight > _YnToastOverlayState._height ? 18 : 999,
                ),
                boxShadow: _toastPillShadows,
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
                        dismissDuration: dismissDuration,
                        spinSnapshotListenable: spinSnapshotListenable,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: isExiting
                        ? Duration.zero
                        : const Duration(milliseconds: 620),
                    curve: Curves.easeOutCubic,
                    width: isExpanded ? maxMessageWidth : 0,
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
    required this.dismissDuration,
    required this.spinSnapshotListenable,
  });

  final YnToastType type;
  final _YnToastPhase phase;
  final Duration dismissDuration;
  final ValueListenable<_SpinSnapshot> spinSnapshotListenable;

  @override
  Widget build(BuildContext context) {
    final isLoading = phase == _YnToastPhase.loading;
    final isSuccess =
        phase == _YnToastPhase.success || phase == _YnToastPhase.exiting;
    final isExiting = phase == _YnToastPhase.exiting;

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
            duration:
                isExiting ? dismissDuration : const Duration(milliseconds: 580),
            curve: Curves.easeOutCubic,
            scale: isSuccess ? 1 : 0.35,
            child: AnimatedOpacity(
              duration:
                  isExiting ? dismissDuration : const Duration(milliseconds: 200),
              opacity: isSuccess ? 1 : 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _toastColor(type),
                ),
                child: const SizedBox.square(dimension: 28),
              ),
            ),
          ),
          AnimatedOpacity(
            duration:
                isExiting ? dismissDuration : const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            opacity: isSuccess ? 1 : 0,
            child: _ToastStatusIcon(
              type: type,
              show: isSuccess,
              animateIn: isSuccess && !isExiting,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToastStatusIcon extends StatelessWidget {
  const _ToastStatusIcon({
    required this.type,
    required this.show,
    required this.animateIn,
  });

  static const _iconColor = Color(0xFFF3EDDF);
  static const _iconSize = 18.0;

  final YnToastType type;
  final bool show;
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      _iconData(type),
      size: _iconSize,
      color: _iconColor,
    );
    if (!animateIn) {
      return show ? icon : const SizedBox.shrink();
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: show ? 1 : 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.55 + t * 0.45,
          child: child,
        ),
      ),
      child: icon,
    );
  }

  static IconData _iconData(YnToastType type) => switch (type) {
        YnToastType.success => Icons.check_rounded,
        YnToastType.info => Icons.info_outline_rounded,
        YnToastType.warning => Icons.warning_amber_rounded,
        YnToastType.error => Icons.priority_high_rounded,
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

const List<BoxShadow> _toastPillShadows = [
  BoxShadow(
    color: Color(0x243E372A),
    blurRadius: 28,
    offset: Offset(0, 14),
  ),
  BoxShadow(
    color: Color(0x143E372A),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

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
