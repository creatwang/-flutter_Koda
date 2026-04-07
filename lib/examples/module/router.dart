import 'package:flutter/material.dart';
import '../page/accounting.dart';
import '../page/home.dart';
import '../page/test.dart';

class CustomRouter {
  const CustomRouter({required this.widget, required this.label});

  final Widget widget;
  final String label;
}

const List<CustomRouter> routerList = [
  CustomRouter(widget: Home(), label: '答题'),
  CustomRouter(widget: Accounting(), label: '记账页面'),
  CustomRouter(widget: TestPage(), label: 'cesium'),
];
