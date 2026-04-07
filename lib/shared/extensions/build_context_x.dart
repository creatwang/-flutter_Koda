import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

extension BuildContextX on BuildContext {
  bool get isTabletUp => ResponsiveBreakpoints.of(this).largerOrEqualTo(TABLET);
}
