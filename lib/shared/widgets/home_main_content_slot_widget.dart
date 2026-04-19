import 'package:flutter/material.dart';

/// 与 [ProfilePage]（含 Settings）主内容区一致：统一外边距与可视高度，
/// 便于 Home 下各 Tab 内容区对齐。
class HomeMainContentSlot extends StatelessWidget {
  const HomeMainContentSlot({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = MediaQuery.sizeOf(context);
        const double heightTrim = 20;
        const double fallbackOffset = 150;
        final fallbackHeight = viewport.height - fallbackOffset;
        final resolvedHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight - heightTrim
            : fallbackHeight;
        final panelHeight =
            resolvedHeight > 0 ? resolvedHeight : fallbackHeight;

        return Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: SizedBox(
            height: panelHeight,
            width: double.infinity,
            child: child,
          ),
        );
      },
    );
  }
}
