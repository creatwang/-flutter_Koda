import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/app/bootstrap/app_shell.dart';

Future<void> main() async {
  runApp(const ProviderScope(child: AppShell()));
}
