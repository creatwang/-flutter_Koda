import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showGlobalErrorMessage(String message) {
  final messenger = appScaffoldMessengerKey.currentState;
  if (messenger == null || message.trim().isEmpty) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message)),
    );
}
