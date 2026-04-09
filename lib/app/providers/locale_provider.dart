import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocaleMode { system, zh, en }

extension AppLocaleModeX on AppLocaleMode {
  Locale? get localeOrNull => switch (this) {
    AppLocaleMode.system => null,
    AppLocaleMode.zh => const Locale('zh'),
    AppLocaleMode.en => const Locale('en'),
  };
}

class AppLocaleModeNotifier extends Notifier<AppLocaleMode> {
  @override
  AppLocaleMode build() => AppLocaleMode.zh;

  void setMode(AppLocaleMode mode) {
    state = mode;
  }
}

final appLocaleModeProvider =
    NotifierProvider<AppLocaleModeNotifier, AppLocaleMode>(
  AppLocaleModeNotifier.new,
);
