import 'package:flutter/material.dart';

class FlowMenu extends StatefulWidget {
  const FlowMenu({super.key});

  @override
  State<FlowMenu> createState() => _FlowMenuState();
}

class _FlowMenuState extends State<FlowMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: MyFlowDelegate(animation: _controller),
      children: [
        _buildItem(Icons.share, Colors.blue),
        _buildItem(Icons.favorite, Colors.red),
        _buildItem(Icons.add_shopping_cart, Colors.orange),
        GestureDetector(
          onTap: () => _controller.isCompleted ? _controller.reverse() : _controller.forward(),
          child: _buildItem(Icons.menu, Colors.black),
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class MyFlowDelegate extends FlowDelegate {
  MyFlowDelegate({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paintChildren(FlowPaintingContext context) {
    const x = 10.0;
    const y = 10.0;

    for (int i = 0; i < context.childCount; i++) {
      if (i == context.childCount - 1) {
        context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
      } else {
        final offset = i * 60.0 * animation.value;
        context.paintChild(i, transform: Matrix4.translationValues(x, y + offset, 0));
      }
    }
  }

  @override
  bool shouldRepaint(MyFlowDelegate oldDelegate) => animation != oldDelegate.animation;
}
