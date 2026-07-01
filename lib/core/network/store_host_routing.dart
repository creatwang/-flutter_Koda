/// 各平台统一直连当前站点 API 根地址（登录/切站后替换 host）。
String resolveRequestBaseUrl({
  required String storeApiBaseUrl,
}) {
  return storeApiBaseUrl;
}

/// 会话级不注入 `x-forwarded-host`。
String? resolveSessionForwardedHost({required String? storeHost}) => null;

/// 仅扫码等显式传入 [explicitForwardedHost] 时注入 `x-forwarded-host`。
String? resolveRequestForwardedHost({
  required String? explicitForwardedHost,
  required String? storeHost,
}) {
  final explicit = explicitForwardedHost?.trim();
  if (explicit != null && explicit.isNotEmpty) return explicit;
  return null;
}
