import 'package:flutter/widgets.dart';
import 'package:george_pick_mate/l10n/app_localizations.dart';

AppLocalizations Function() _resolver =
    () => lookupAppLocalizations(const Locale('en'));

/// 在 [MaterialApp] builder 中绑定，供无 [BuildContext] 的层获取当前语言文案。
void bindAppLocalizationsResolver(AppLocalizations Function() resolver) {
  _resolver = resolver;
}

/// 当前应用语言的 [AppLocalizations]（依赖 [bindAppLocalizationsResolver]）。
AppLocalizations get appL10n => _resolver();
