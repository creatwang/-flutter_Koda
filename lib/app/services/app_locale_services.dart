import 'package:shared_preferences/shared_preferences.dart';

const String _appLocaleModeStorageKey = 'app_locale_mode_v1';

const Set<String> _supportedAppLocaleModeValues = {'system', 'zh', 'en'};

/// 从本地读取已保存的语言模式键（`system` / `zh` / `en`）。
Future<String?> readPersistedAppLocaleModeRaw() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_appLocaleModeStorageKey);
    if (raw != null && _supportedAppLocaleModeValues.contains(raw)) {
      return raw;
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// 将语言模式键写入本地。
Future<void> persistAppLocaleModeRaw(String value) async {
  if (!_supportedAppLocaleModeValues.contains(value)) return;
  try {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appLocaleModeStorageKey, value);
  } catch (_) {
    // SharedPreferences 在部分测试环境未初始化，允许安全降级。
  }
}
