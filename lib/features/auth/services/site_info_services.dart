import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/auth/api/auth_requests.dart';
import 'package:groe_app_pad/features/auth/models/site_info_dto.dart';
import 'package:groe_app_pad/shared/business_plugin/business_plugin_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _siteInfoStorageKey = 'site_info_v1';

Future<ApiResult<SiteInfoDto>> fetchSiteInfoService({
  required int companyId,
}) async {
  try {
    final response = await requestSiteInfo(companyId: companyId);
    final siteInfo = SiteInfoDto.fromDio(response.data);
    return ApiSuccess(siteInfo);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch site info failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<void> syncSiteInfoToLocal({required int companyId}) async {
  final result = await fetchSiteInfoService(companyId: companyId);
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
