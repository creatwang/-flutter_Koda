import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/app/bootstrap/app_shell.dart';
import 'package:george_pick_mate/app/providers/locale_provider.dart';
import 'package:george_pick_mate/app/services/app_locale_services.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await storeHostController.restoreFromStorage();
  final persistedLocaleRaw = await readPersistedAppLocaleModeRaw();
  final initialLocaleMode = appLocaleModeFromStorage(persistedLocaleRaw);
  bindAppLocalizationsResolver(
    () => lookupAppLocalizations(
      initialLocaleMode.localeOrNull ?? const Locale('en'),
    ),
  );

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
