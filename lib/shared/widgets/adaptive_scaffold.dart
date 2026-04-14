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
    this.bottomNavigationBar,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     /* appBar: AppBar(
        title: Text(title),
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: mergedActions,
        bottom: bottom,
        shadowColor: Colors.grey,
      ),*/
      floatingActionButton: floatingActionButton,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
