import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/app/app.dart';

void main() {
  runApp(const ProviderScope(child: App()));
  /*runApp(const MaterialApp(
    home: Scaffold(
      body: CustomMenu(),
    ),
  ));*/
}
