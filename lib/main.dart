import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/app/bootstrap/app_shell.dart';
import 'package:george_pick_mate/app/providers/locale_provider.dart';
import 'package:george_pick_mate/app/services/app_locale_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final persistedLocaleRaw = await readPersistedAppLocaleModeRaw();
  final initialLocaleMode = appLocaleModeFromStorage(persistedLocaleRaw);

  runApp(
    ProviderScope(
      overrides: [
        appLocaleModeProvider.overrideWith(
          () => AppLocaleModeNotifier(initialMode: initialLocaleMode),
        ),
      ],
      child: const AppShell(),
    ),
  );
}
