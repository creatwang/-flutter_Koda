import 'package:flutter/material.dart';

/// 点击子树中「非子组件认领」的区域时收起键盘（释放焦点）。
/// 使用 [HitTestBehavior.deferToChild]，子组件（如 [TextField]、按钮）优先接收
/// 点击，避免误抢输入框焦点；空白区域由本组件接收并 [unfocus]。
class DismissKeyboardOnTap extends StatelessWidget {
  const DismissKeyboardOnTap({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
