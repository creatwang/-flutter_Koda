import 'package:flutter/material.dart';
import '../page/accounting.dart';
import '../page/detail.dart';
import '../page/home.dart';
import '../page/test.dart';
import '../page/user.dart';

class CustomRouter {
  const CustomRouter({required this.widget, required this.label});

  final Widget widget;
  final String label;
}

final List<CustomRouter> routerList = [
  CustomRouter(widget: Home(), label: '答题'),
  CustomRouter(widget: Accounting(), label: '记账页面'),
  CustomRouter(widget: TestPage(), label: 'cesium'),
  CustomRouter(widget: UserPage(), label: 'user'),
  CustomRouter(
    widget: Detail(),
    label: 'detail',
  ),
];
