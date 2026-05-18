import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/shared/base_widget/toast/yn_toast_widget.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_george_confirm_dialog.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_george_session_expired_dialog.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// 置于 [MaterialApp.builder] 最顶层的 Overlay，避免 Toast 被装饰层挡住。
final GlobalKey<OverlayState> appToastOverlayKey = GlobalKey<OverlayState>();

typedef SessionExpiredHandler = Future<void> Function();
SessionExpiredHandler? _sessionExpiredHandler;
bool _sessionExpiredDialogShowing = false;
bool _cartUnorderedItemsDialogShowing = false;

void registerSessionExpiredHandler(SessionExpiredHandler handler) {
  _sessionExpiredHandler = handler;
}

BuildContext? _globalToastContext(BuildContext? context) {
  final ctx = context ??
      appNavigatorKey.currentContext ??
      appScaffoldMessengerKey.currentContext;
  if (ctx == null || !ctx.mounted) return null;
  return ctx;
}

YnToastController? _beginGlobalYnToastLoading({
  BuildContext? context,
  YnToastType type = YnToastType.info,
  bool mask = false,
}) {
  final overlay = appToastOverlayKey.currentState;
  if (overlay != null) {
    return YnToast.showLoadingOnOverlay(
      overlay,
      type: type,
      mask: mask,
    );
  }
  final ctx = _globalToastContext(context);
  if (ctx == null) return null;
  return YnToast.show(
    ctx,
    type: type,
    options: YnToastShowOptions(
      loadingDuration: const Duration(days: 1),
      persist: true,
      mask: mask,
    ),
  );
}

/// 包裹异步任务：先展示 YnToast loading，结束后用 [YnToastController.done] 切
/// success / error。返回 `null` 表示成功，非空字符串为错误文案。
///
/// [successMessage] 为空时以 success 态收起 loading（无文案），
/// 避免 loading 默认 info 在退出动画中误展示为 info。
/// [successHold]：成功 [done] 后额外等待时长，便于用户看到反馈再跳转。
Future<String?> runGlobalYnToastTask({
  required Future<String?> Function() task,
  BuildContext? context,
  String? successMessage,
  Duration successDuration = const Duration(milliseconds: 450),
  Duration successHold = Duration.zero,
  Duration errorDuration = const Duration(milliseconds: 2600),
  bool mask = false,
}) async {
  final controller = _beginGlobalYnToastLoading(context: context, mask: mask);
  if (controller == null) {
    return task();
  }

  try {
    final errorMessage = await task();
    if (errorMessage == null) {
      if (successMessage != null && successMessage.trim().isNotEmpty) {
        controller.done(
          YnToastType.success,
          message: successMessage.trim(),
          options: YnToastDoneOptions(duration: successDuration),
        );
        if (successHold > Duration.zero) {
          await Future<void>.delayed(successHold);
        }
      } else {
        controller.done(
          YnToastType.success,
          message: '',
          options: YnToastDoneOptions(duration: successDuration),
        );
        if (successHold > Duration.zero) {
          await Future<void>.delayed(successHold);
        }
      }
      return null;
    }
    controller.done(
      YnToastType.error,
      message: errorMessage.trim(),
      options: YnToastDoneOptions(duration: errorDuration),
    );
    return errorMessage;
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
    final message = error is AppException
        ? error.message
        : error.toString();
    controller.done(
      YnToastType.error,
      message: message,
      options: YnToastDoneOptions(duration: errorDuration),
    );
    return message;
  }
}

void _showGlobalYnToast(
  YnToastType type,
  String message, {
  BuildContext? context,
}) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return;

  final overlay = appToastOverlayKey.currentState;
  if (overlay != null) {
    YnToast.showOnOverlay(overlay, type: type, message: trimmed);
    return;
  }

  final ctx = _globalToastContext(context);
  if (ctx == null) return;
  switch (type) {
    case YnToastType.success:
      YnToast.success(ctx, message: trimmed);
    case YnToastType.warning:
      YnToast.warning(ctx, message: trimmed);
    case YnToastType.error:
      YnToast.error(ctx, message: trimmed);
    case YnToastType.info:
      YnToast.info(ctx, message: trimmed);
  }
}

/// 全局错误/失败类提示（顶部 [YnToast.error]）。
///
/// 保留此函数名以兼容既有调用；展示载体为 YnToast，非底部 SnackBar。
/// [context] 可选；未传时使用 [appNavigatorKey] 或
/// [appScaffoldMessengerKey] 的上下文。
void showGlobalErrorMessage(
  String message, {
  BuildContext? context,
}) {
  _showGlobalYnToast(YnToastType.error, message, context: context);
}

/// 全局成功/完成类提示（顶部 [YnToast.success]）。
///
/// 保留此函数名以兼容既有调用；展示载体为 YnToast，非底部 SnackBar。
/// [context] 可选；未传时使用 [appNavigatorKey] 或
/// [appScaffoldMessengerKey] 的上下文。
void showGlobalSnackBar(
  String message, {
  BuildContext? context,
}) {
  _showGlobalYnToast(YnToastType.success, message, context: context);
}

/// 全局约束/校验类提示（顶部 [YnToast.warning]）。
///
/// [context] 可选；未传时使用 [appNavigatorKey] 或
/// [appScaffoldMessengerKey] 的上下文。
void showGlobalWarningMessage(
  String message, {
  BuildContext? context,
}) {
  _showGlobalYnToast(YnToastType.warning, message, context: context);
}

/// 加购返回 `code == 100000`：提示未下单商品并可选跳转购物车 Tab。
Future<void> showCartUnorderedItemsConfirmDialog(String message) async {
  if (_cartUnorderedItemsDialogShowing) return;
  _cartUnorderedItemsDialogShowing = true;
  final rootContext =
      appNavigatorKey.currentContext ?? appScaffoldMessengerKey.currentContext;
  if (rootContext == null) {
    _cartUnorderedItemsDialogShowing = false;
    return;
  }
  final trimmed = message.trim();
  final result = await showGeorgeConfirmDialog(
    context: rootContext,
    title: 'Notice',
    message: trimmed.isEmpty
        ? 'There are still unordered items in the shopping cart.'
        : trimmed,
    cancelLabel: 'Cancel',
    confirmLabel: 'Go to Cart',
    icon: Icons.shopping_cart_outlined,
    accentColor: const Color(0xFFFF8B6A),
  );
  if (result == true && rootContext.mounted) {
    GoRouter.of(rootContext).go(AppRoutes.homeWithTab('cart'));
  }
  _cartUnorderedItemsDialogShowing = false;
}

Future<void> showSessionExpiredDialog(String message) async {
  if (_sessionExpiredDialogShowing) return;
  _sessionExpiredDialogShowing = true;
  final rootContext =
      appNavigatorKey.currentContext ?? appScaffoldMessengerKey.currentContext;
  if (rootContext == null) {
    _sessionExpiredDialogShowing = false;
    return;
  }
  await showGeorgeSessionExpiredDialog(
    context: rootContext,
    useRootNavigator: true,
    title: 'Session ended',
    message: message.trim().isEmpty
        ? 'Please sign in again to continue shopping.'
        : message.trim(),
    actionLabel: 'Sign in again',
    onAction: () async {
      await _sessionExpiredHandler?.call();
      if (rootContext.mounted) {
        GoRouter.of(rootContext).go(AppRoutes.login);
      }
    },
  );

  _sessionExpiredDialogShowing = false;
}
