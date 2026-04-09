import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/app/bootstrap/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: AppShell()));
}
