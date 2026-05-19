import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/app/services/app_locale_services.dart';

enum AppLocaleMode { system, zh, en }

extension AppLocaleModeX on AppLocaleMode {
  Locale? get localeOrNull => switch (this) {
    AppLocaleMode.system => null,
    AppLocaleMode.zh => const Locale('zh'),
    AppLocaleMode.en => const Locale('en'),
  };

  String get storageValue => name;
}

AppLocaleMode appLocaleModeFromStorage(String? raw) => switch (raw) {
  'system' => AppLocaleMode.system,
  'zh' => AppLocaleMode.zh,
  'en' => AppLocaleMode.en,
  _ => AppLocaleMode.en,
};

class AppLocaleModeNotifier extends Notifier<AppLocaleMode> {
  AppLocaleModeNotifier({this.initialMode});

  final AppLocaleMode? initialMode;

  static const AppLocaleMode _defaultMode = AppLocaleMode.en;

  @override
  AppLocaleMode build() {
    if (initialMode == null) {
      unawaited(_hydrateFromStorage());
    }
    return initialMode ?? _defaultMode;
  }

  Future<void> _hydrateFromStorage() async {
    final raw = await readPersistedAppLocaleModeRaw();
    if (raw == null) return;
    final mode = appLocaleModeFromStorage(raw);
    if (state != mode) {
      state = mode;
    }
  }

  void setMode(AppLocaleMode mode) {
    if (state == mode) return;
    state = mode;
    unawaited(persistAppLocaleModeRaw(mode.storageValue));
  }
}

final appLocaleModeProvider =
    NotifierProvider<AppLocaleModeNotifier, AppLocaleMode>(
  AppLocaleModeNotifier.new,
);
