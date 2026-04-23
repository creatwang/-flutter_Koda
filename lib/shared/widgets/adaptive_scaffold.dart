import 'package:flutter/material.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';

enum AdaptiveBottomBarVisibility {
  always,
  mobileOnly,
  never,
}

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
    this.bottomBarVisibility = AdaptiveBottomBarVisibility.always,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? bottomNavigationBar;
  final AdaptiveBottomBarVisibility bottomBarVisibility;

  @override
  Widget build(BuildContext context) {
    final resolvedBottomBar = _resolveBottomNavigationBar(context);
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
      bottomNavigationBar: resolvedBottomBar,
    );
  }

  Widget? _resolveBottomNavigationBar(BuildContext context) {
    if (bottomNavigationBar == null) return null;

    return switch (bottomBarVisibility) {
      AdaptiveBottomBarVisibility.always => bottomNavigationBar,
      AdaptiveBottomBarVisibility.mobileOnly =>
        context.isTabletUp ? null : bottomNavigationBar,
      AdaptiveBottomBarVisibility.never => null,
    };
  }
}
