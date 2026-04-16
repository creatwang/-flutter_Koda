import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groe_app_pad/app/router/app_routes.dart';

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

  await _sessionExpiredHandler?.call();
  final messenger = appScaffoldMessengerKey.currentState;
  final rootContext =
      appNavigatorKey.currentContext ?? appScaffoldMessengerKey.currentContext;
  if (rootContext == null) {
    _sessionExpiredDialogShowing = false;
    return;
  }
  messenger?.hideCurrentSnackBar();

  await showDialog<void>(
    context: rootContext,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.78),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          title: const Text(
            'Session Expired',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Login expired, please log in again.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                GoRouter.of(rootContext).go(AppRoutes.login);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    },
  );

  _sessionExpiredDialogShowing = false;
}
