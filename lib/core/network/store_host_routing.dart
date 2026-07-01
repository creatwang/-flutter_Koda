import 'package:flutter/foundation.dart';
import 'package:george_pick_mate/core/config/env.dart';

/// Web 跨域：固定打 [Env.baseUrl] 网关，站点用 `x-forwarded-host` 传递。
/// Pad/原生：直接切换 [storeApiBaseUrl]。
String resolveRequestBaseUrl({
  required String storeApiBaseUrl,
  bool isWeb = kIsWeb,
  String envBaseUrl = Env.baseUrl,
}) {
  if (isWeb) return envBaseUrl;
  return storeApiBaseUrl;
}

/// Web 且当前站点 host 与网关 host 不同时，注入会话级 `x-forwarded-host`。
String? resolveSessionForwardedHost({
  required String? storeHost,
  bool isWeb = kIsWeb,
  String envBaseUrl = Env.baseUrl,
}) {
  if (!isWeb) return null;

  final normalized = storeHost?.trim();
  if (normalized == null || normalized.isEmpty) return null;

  final envHost = Uri.parse(envBaseUrl).host;
  if (normalized == envHost) return null;

  return normalized;
}

/// 扫码 [explicitForwardedHost] 优先；否则 Web 会话站点。
String? resolveRequestForwardedHost({
  required String? explicitForwardedHost,
  required String? storeHost,
  bool isWeb = kIsWeb,
  String envBaseUrl = Env.baseUrl,
}) {
  final explicit = explicitForwardedHost?.trim();
  if (explicit != null && explicit.isNotEmpty) return explicit;

  return resolveSessionForwardedHost(
    storeHost: storeHost,
    isWeb: isWeb,
    envBaseUrl: envBaseUrl,
  );
}
