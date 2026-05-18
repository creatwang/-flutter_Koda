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
    with TickerProviderStateMixin {
  static const _height = 36.0;
  static const _ballSize = 32.0;
  static const _top = 26.0;
  static const _messagePadding = EdgeInsets.only(left: 6, right: 14);
  static const _spinRampDuration = Duration(milliseconds: 1400);
  static const _expandDuration = Duration(milliseconds: 620);
  static const _exitDuration = Duration(milliseconds: 320);
  static const _quickExitDuration = Duration(milliseconds: 180);

  late final Ticker _spinTicker;
  late final ValueNotifier<_SpinSnapshot> _spinSnapshotNotifier;
  late final ValueNotifier<double> _swipeYOffset;
  late final AnimationController _exitController;
  late final Animation<double> _exitAnimation;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
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
  double _swipeStartY = 0;
  bool _isQuickExit = false;
  double _accumulatedAngleRad = 0;
  double _accumulatedRingOpacity = 0.92;
  int _spinFrameCounter = 0;

  @override
  void initState() {
    super.initState();
    _swipeYOffset = ValueNotifier(0);
    _exitController = AnimationController(
      vsync: this,
      duration: _exitDuration,
    );
    _exitAnimation = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeOutCubic,
    );
    _expandController = AnimationController(
      vsync: this,
      duration: _expandDuration,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
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
    _exitController.dispose();
    _expandController.dispose();
    _spinTicker.dispose();
    _spinSnapshotNotifier.dispose();
    _swipeYOffset.dispose();
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
        (_accumulatedAngleRad * 180 / math.pi + speedDegPerSecond * dt) % 360;
    final visualSoftness = (progress * 1.35).clamp(0.0, 1.0);
    _accumulatedAngleRad = spinAngleDeg * (math.pi / 180);
    _accumulatedRingOpacity = 0.92 - visualSoftness * 0.22;
    _spinFrameCounter++;
    if (_spinFrameCounter % 2 != 0) return;
    _spinSnapshotNotifier.value = _SpinSnapshot(
      angleRad: _accumulatedAngleRad,
      ringOpacity: _accumulatedRingOpacity,
    );
  }

  void _startSpin() {
    _spinEpochElapsed = null;
    _lastSpinElapsed = Duration.zero;
    _spinFrameCounter = 0;
    _accumulatedAngleRad = 0;
    _accumulatedRingOpacity = 0.92;
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
    final wasLoading = _phase == _YnToastPhase.loading;
    _cachedSize = null;
    setState(() {
      _type = type;
      _message = _resolveMessage(type, message);
      _hasMessage = _message.trim().isNotEmpty;
      _loadingMask = false;
      _phase = _YnToastPhase.success;
    });
    _swipeYOffset.value = 0;
    if (wasLoading) {
      _expandController.forward(from: 0);
    } else {
      _expandController.value = 1;
    }
    if (options.persist) return;
    _hideTimer = Timer(options.duration, hide);
  }

  void hide({bool quick = false}) {
    if (!mounted || _isRemoved) return;
    if (_phase == _YnToastPhase.exiting) return;
    _clearTimers();
    _stopSpin();
    // 仅从 loading 收起：勿走 exiting（会按 initialType 展开成 info!/error! 等）。
    if (_phase == _YnToastPhase.loading) {
      _removeEntry();
      return;
    }
    _isQuickExit = quick;
    final dismissDuration = quick ? _quickExitDuration : _exitDuration;
    _exitController.duration = dismissDuration;
    if (_exitController.isAnimating) {
      _exitController.stop();
    }
    setState(() {
      _loadingMask = false;
      _phase = _YnToastPhase.exiting;
    });
    _swipeYOffset.value = 0;
    _exitController.forward(from: 0).whenComplete(() {
      if (mounted && !_isRemoved) {
        _removeEntry();
      }
    });
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
      _expandController.value = 0;
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
    _swipeYOffset.value = math.min(0, deltaY);
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_swipeYOffset.value < -32) {
      hide();
      return;
    }
    _swipeYOffset.value = 0;
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
    final ignoreToastPointer =
        _phase == _YnToastPhase.idle || _phase == _YnToastPhase.exiting;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.9;
    final size = _measureToastSize(context, maxWidth);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_loadingMask && _phase == _YnToastPhase.loading)
          Positioned.fill(
            child: AbsorbPointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _withAlpha(const Color(0xFF20231D), 0.18),
                ),
              ),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: ignoreToastPointer,
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.only(top: _top),
                child: Center(
                  child: RepaintBoundary(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _swipeYOffset,
                      builder: (context, swipeY, child) {
                        return Transform.translate(
                          offset: Offset(0, swipeY),
                          child: child,
                        );
                      },
                      child: _ToastPill(
                        key: const ValueKey<String>('yn-toast-pill'),
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
                        expandAnimation: _expandAnimation,
                        exitAnimation: _phase == _YnToastPhase.exiting
                            ? _exitAnimation
                            : null,
                        spinSnapshotListenable: _spinSnapshotNotifier,
                        onVerticalDragStart: _handleVerticalDragStart,
                        onVerticalDragUpdate: _handleVerticalDragUpdate,
                        onVerticalDragEnd: _handleVerticalDragEnd,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastPill extends StatefulWidget {
  const _ToastPill({
    super.key,
    required this.phase,
    required this.type,
    required this.message,
    required this.hasMessage,
    required this.width,
    required this.height,
    required this.maxMessageWidth,
    required this.shouldWrapMessage,
    required this.dismissDuration,
    required this.expandAnimation,
    required this.exitAnimation,
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
  final Animation<double> expandAnimation;
  final Animation<double>? exitAnimation;
  final ValueListenable<_SpinSnapshot> spinSnapshotListenable;
  final GestureDragStartCallback onVerticalDragStart;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  State<_ToastPill> createState() => _ToastPillState();
}

class _ToastPillState extends State<_ToastPill> {
  bool _showFullShadow = true;
  Timer? _shadowTimer;

  @override
  void didUpdateWidget(covariant _ToastPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase == _YnToastPhase.loading &&
        widget.phase == _YnToastPhase.success) {
      _showFullShadow = false;
      _shadowTimer?.cancel();
      _shadowTimer = Timer(_YnToastOverlayState._expandDuration, () {
        if (mounted) setState(() => _showFullShadow = true);
      });
    }
    if (widget.phase == _YnToastPhase.loading) {
      _showFullShadow = false;
    }
  }

  @override
  void dispose() {
    _shadowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExiting = widget.phase == _YnToastPhase.exiting;
    final isActive = widget.phase == _YnToastPhase.loading ||
        widget.phase == _YnToastPhase.success;

    final Widget pillBody;
    if (isExiting) {
      pillBody = _buildPillBody(expandProgress: 1);
    } else {
      pillBody = AnimatedBuilder(
        animation: widget.expandAnimation,
        builder: (context, child) {
          final progress = widget.phase == _YnToastPhase.loading
              ? 0.0
              : widget.expandAnimation.value;
          return _buildPillBody(expandProgress: progress);
        },
      );
    }

    Widget content;
    if (isExiting && widget.exitAnimation != null) {
      content = AnimatedBuilder(
        animation: widget.exitAnimation!,
        builder: (context, child) {
          final t = widget.exitAnimation!.value;
          return Opacity(
            opacity: 1 - t,
            child: Transform.translate(
              offset: Offset(0, -14 * t),
              child: Transform.scale(
                scale: 1 - 0.06 * t,
                child: child,
              ),
            ),
          );
        },
        child: pillBody,
      );
    } else {
      content = AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        opacity: isActive ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          offset: isActive ? Offset.zero : const Offset(0, -0.333),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            scale: isActive ? 1 : 0.92,
            child: pillBody,
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: widget.onVerticalDragStart,
      onVerticalDragUpdate: widget.onVerticalDragUpdate,
      onVerticalDragEnd: widget.onVerticalDragEnd,
      child: content,
    );
  }

  Widget _buildPillBody({required double expandProgress}) {
    final collapsed = _YnToastOverlayState._height;
    final t = expandProgress.clamp(0.0, 1.0);
    final displayWidth = collapsed + (widget.width - collapsed) * t;
    final displayHeight = collapsed + (widget.height - collapsed) * t;
    final borderRadius =
        displayHeight > collapsed + 0.5 ? 18.0 : displayHeight / 2;
    final showMessage = widget.hasMessage && t > 0;
    final shadows =
        _showFullShadow ? _toastPillShadows : _toastPillShadowsExpanding;

    return RepaintBoundary(
      child: Container(
        width: displayWidth,
        height: displayHeight,
        decoration: BoxDecoration(
          boxShadow: shadows,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: ColoredBox(
            color: _withAlpha(const Color(0xFFF6F1E6), 0.92),
            child: Row(
              crossAxisAlignment: displayHeight > collapsed
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: collapsed,
                  height: displayHeight,
                  child: Center(
                    child: _ToastBall(
                      type: widget.type,
                      phase: widget.phase,
                      dismissDuration: widget.dismissDuration,
                      spinSnapshotListenable: widget.spinSnapshotListenable,
                    ),
                  ),
                ),
                SizedBox(
                  width: widget.maxMessageWidth * t,
                  child: Padding(
                    padding: _YnToastOverlayState._messagePadding,
                    child: Opacity(
                      opacity: showMessage ? t : 0,
                      child: Text(
                        widget.message,
                        softWrap: widget.shouldWrapMessage,
                        maxLines: widget.shouldWrapMessage ? null : 1,
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

    return RepaintBoundary(
      child: SizedBox.square(
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
                    painter: _ToastYPetalPainter(
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

/// 三瓣 Y 环 loading（与参考 SVG 同路径，整体随 [spinAngleRad] 旋转）。
///
/// ```svg
/// <path d="M22 6a16 16 0 0 1 13.9 22"/>
/// <path d="M35.856 30a16 16 0 0 1-26.002 1.038" opacity=".65"/>
/// <path d="M8.144 30A16 16 0 0 1 20.246 6.962" opacity=".35"/>
/// ```
class _ToastYPetalPainter extends CustomPainter {
  const _ToastYPetalPainter({
    required this.spinAngleRad,
    required this.ringOpacity,
  });

  static const _viewSize = 44.0;
  static const _center = Offset(22, 22);
  static const _radius = 16.0;
  static const _strokeWidth = 3.5;
  static const _baseColor = Color(0xFF333333);
  static const _petalOpacities = <double>[1.0, 0.65, 0.35];
  static const _petalArcs = <(Offset start, Offset end)>[
    (Offset(22, 6), Offset(35.9, 28)),
    (Offset(35.856, 30), Offset(9.854, 31.038)),
    (Offset(8.144, 30), Offset(20.246, 6.962)),
  ];

  final double spinAngleRad;
  final double ringOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewSize;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(_center.dx, _center.dy);
    canvas.rotate(spinAngleRad);
    canvas.translate(-_center.dx, -_center.dy);

    for (var i = 0; i < _petalArcs.length; i++) {
      final arc = _petalArcs[i];
      final paint = Paint()
        ..color = _withAlpha(_baseColor, ringOpacity * _petalOpacities[i])
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _strokeWidth;
      _drawSvgSweepArc(
        canvas,
        center: _center,
        radius: _radius,
        start: arc.$1,
        end: arc.$2,
        paint: paint,
      );
    }
    canvas.restore();
  }

  /// 与 SVG `A/a` 一致：sweep-flag=1，取顺时针弧段。
  static void _drawSvgSweepArc(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Offset start,
    required Offset end,
    required Paint paint,
  }) {
    final startAngle = math.atan2(start.dy - center.dy, start.dx - center.dx);
    final endAngle = math.atan2(end.dy - center.dy, end.dx - center.dx);
    var sweep = endAngle - startAngle;
    while (sweep <= 0) {
      sweep += math.pi * 2;
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ToastYPetalPainter oldDelegate) {
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

const List<BoxShadow> _toastPillShadowsExpanding = [
  BoxShadow(
    color: Color(0x183E372A),
    blurRadius: 10,
    offset: Offset(0, 4),
  ),
];

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
