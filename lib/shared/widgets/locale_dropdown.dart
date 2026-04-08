import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/app/providers/locale_provider.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

class LocaleDropdown extends ConsumerWidget {
  const LocaleDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appLocaleModeProvider);
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (mode) {
      AppLocaleMode.system => l10n.languageSystem,
      AppLocaleMode.zh => l10n.languageChinese,
      AppLocaleMode.en => l10n.languageEnglish,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999)
        ),
        child: PopupMenuButton<AppLocaleMode>(
          tooltip: l10n.languageLabel,
          onSelected: (value) => ref.read(appLocaleModeProvider.notifier).setMode(value),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: AppLocaleMode.system,
              child: Text(l10n.languageSystem),
            ),
            PopupMenuItem(
              value: AppLocaleMode.zh,
              child: Text(l10n.languageChinese),
            ),
            PopupMenuItem(
              value: AppLocaleMode.en,
              child: Text(l10n.languageEnglish),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 18,
                  color:  colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color:  colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
