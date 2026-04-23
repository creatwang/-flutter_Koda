import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/app/providers/locale_provider.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';

class LocaleDropdown extends ConsumerWidget {
  const LocaleDropdown({super.key});
  static const double _radius = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appLocaleModeProvider);
    final l10n = context.l10n;
    final iconTextColor =
        Theme.of(context).appBarTheme.foregroundColor ??
        (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87);
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
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: PopupMenuButton<AppLocaleMode>(
          tooltip: l10n.languageLabel,
          borderRadius: BorderRadius.circular(_radius),
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
                  color: iconTextColor,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: iconTextColor,
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
