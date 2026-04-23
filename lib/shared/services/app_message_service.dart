import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:george_pick_mate/app/router/app_routes.dart';
import 'package:george_pick_mate/shared/widgets/dialog/show_mall_session_expired_dialog.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

typedef SessionExpiredHandler = Future<void> Function();
SessionExpiredHandler? _sessionExpiredHandler;
bool _sessionExpiredDialogShowing = false;

void registerSessionExpiredHandler(SessionExpiredHandler handler) {
  _sessionExpiredHandler = handler;
}

void showGlobalErrorMessage(String message) {
  final messenger = appScaffoldMessengerKey.currentState;
  if (messenger == null || message.trim().isEmpty) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message)),
    );
}

Future<void> showSessionExpiredDialog(String message) async {
  if (_sessionExpiredDialogShowing) return;
  _sessionExpiredDialogShowing = true;
  final messenger = appScaffoldMessengerKey.currentState;
  final rootContext =
      appNavigatorKey.currentContext ?? appScaffoldMessengerKey.currentContext;
  if (rootContext == null) {
    _sessionExpiredDialogShowing = false;
    return;
  }
  messenger?.hideCurrentSnackBar();

  await showMallSessionExpiredDialog(
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
