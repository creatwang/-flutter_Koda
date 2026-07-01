import 'package:george_pick_mate/core/config/env.dart';
import 'package:george_pick_mate/core/storage/secure_storage_service.dart';

/// 运行时 API 域名：登录/切站后切换 [apiBaseUrl]，登出恢复 [Env.baseUrl]。
class StoreHostController {
  StoreHostController(this._storage);

  final SecureStorageService _storage;

  String _apiBaseUrl = Env.baseUrl;
  String? _host;

  String get apiBaseUrl => _apiBaseUrl;

  String? get host => _host;

  Future<void> restoreFromStorage() async {
    final domain = await _storage.getStoreDomain();
    if (domain != null && domain.isNotEmpty) {
      _applyInMemory(domain);
      return;
    }
    _resetInMemory();
  }

  Future<void> applyDomain(String rawHost, {bool persist = true}) async {
    final host = normalizeStoreHost(rawHost);
    if (host.isEmpty) {
      throw ArgumentError.value(rawHost, 'rawHost', 'empty store host');
    }
    if (persist) {
      await _storage.saveStoreDomain(host);
    }
    _applyInMemory(host);
  }

  Future<void> resetToDefault({bool persist = true}) async {
    if (persist) {
      await _storage.deleteStoreDomain();
    }
    _resetInMemory();
  }

  void _applyInMemory(String host) {
    _host = host;
    _apiBaseUrl = buildApiBaseUrl(host);
  }

  void _resetInMemory() {
    _host = null;
    _apiBaseUrl = Env.baseUrl;
  }
}

/// 纯 host → 与 [Env.baseUrl] 同 scheme/路径前缀的 API 根地址。
///
/// 测试包：`https://{host}/testapi`；正式包：`https://{host}/api`。
/// host 来自登录/切站 domain，路径前缀来自构建时的 [Env.baseUrl]。
String buildApiBaseUrl(String host) =>
    '${Env.apiScheme}://${normalizeStoreHost(host)}${Env.apiPathPrefix}';

/// 规范化后端返回的 domain（纯 host；兼容误带 scheme/path）。
String normalizeStoreHost(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return value;

  if (value.startsWith('https://')) {
    value = value.substring(8);
  } else if (value.startsWith('http://')) {
    value = value.substring(7);
  }

  final slashIndex = value.indexOf('/');
  if (slashIndex >= 0) {
    value = value.substring(0, slashIndex);
  }

  return value.trim();
}

/// 从扫码 URL 提取 host，供 `x-forwarded-host` 使用。
String? extractForwardedHostFromScanUrl(String rawCode) {
  final trimmed = rawCode.trim();
  if (trimmed.isEmpty) return null;

  final lower = trimmed.toLowerCase();
  String payload;
  if (lower.startsWith('url,')) {
    payload = trimmed.substring(4).trim();
  } else if (lower.startsWith('http://') || lower.startsWith('https://')) {
    payload = trimmed;
  } else {
    return null;
  }

  final uri = Uri.tryParse(payload);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  final host = uri.host.trim();
  return host.isEmpty ? null : host;
}
