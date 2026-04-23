import 'package:flutter/material.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

extension BuildContextX on BuildContext {
  bool get isTabletUp => ResponsiveBreakpoints.of(this).largerOrEqualTo(TABLET);
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
