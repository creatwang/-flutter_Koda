import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/api/auth_requests.dart';
import 'package:george_pick_mate/features/auth/models/site_info_dto.dart';
import 'package:george_pick_mate/shared/business_plugin/business_plugin_services.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _siteInfoStorageKey = 'site_info_v1';

Future<ApiResult<SiteInfoDto>> fetchSiteInfoService() async {
  try {
    final response = await requestSiteInfo();
    final siteInfo = SiteInfoDto.fromDio(response.data);
    return ApiSuccess(siteInfo);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? appL10n.errorFetchSiteInfoFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<void> syncSiteInfoToLocal() async {
  final result = await fetchSiteInfoService();
  await result.when(
    success: (siteInfo) => saveSiteInfoToLocal(siteInfo: siteInfo),
    failure: (_) async => clearSiteInfoFromLocal(),
  );
}

Future<void> saveSiteInfoToLocal({required SiteInfoDto siteInfo}) async {
  final preferences = await SharedPreferences.getInstance();
  final encoded = jsonEncode(siteInfo.toJson());
  await preferences.setString(_siteInfoStorageKey, encoded);
}

Future<SiteInfoDto?> readSiteInfoFromLocal() async {
  final preferences = await SharedPreferences.getInstance();
  final rawJson = preferences.getString(_siteInfoStorageKey);
  if (rawJson == null || rawJson.isEmpty) return null;
  try {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) return null;
    return SiteInfoDto.fromJson(decoded);
  } catch (_) {
    return null;
  }
}

Future<bool> readExportQuotationCapabilityFromLocal() async {
  return readBusinessPluginCapabilityFromLocal(
    pluginKey: BusinessPluginKeys.exportQuotation,
  );
}

Future<bool> readBusinessPluginCapabilityFromLocal({
  required String pluginKey,
}) async {
  final siteInfo = await readSiteInfoFromLocal();
  return hasBusinessPlugin(
    pluginUniqids: siteInfo?.pluginUniqid,
    pluginKey: pluginKey,
  );
}

Future<void> clearSiteInfoFromLocal() async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(_siteInfoStorageKey);
}

bool hasExportQuotationCapability(SiteInfoDto siteInfo) {
  return hasBusinessPlugin(
    pluginUniqids: siteInfo.pluginUniqid,
    pluginKey: BusinessPluginKeys.exportQuotation,
  );
}
