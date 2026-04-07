import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.title,
    required this.body,
    super.key,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: actions,
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
