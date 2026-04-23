import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/api/auth_requests.dart';
import 'package:george_pick_mate/features/auth/models/site_info_dto.dart';
import 'package:george_pick_mate/shared/business_plugin/business_plugin_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _siteInfoStorageKey = 'site_info_v1';

/// 拉取远端站点配置并转为 [SiteInfoDto]。
///
/// [companyId]：当前站点 id。
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

/// 拉取站点信息并写入本地；失败则清空本地缓存。
Future<void> syncSiteInfoToLocal({required int companyId}) async {
  final result = await fetchSiteInfoService(companyId: companyId);
  await result.when(
    success: (siteInfo) => saveSiteInfoToLocal(siteInfo: siteInfo),
    failure: (_) async => clearSiteInfoFromLocal(),
  );
}

/// 持久化 [SiteInfoDto] 到 [SharedPreferences]。
Future<void> saveSiteInfoToLocal({required SiteInfoDto siteInfo}) async {
  final preferences = await SharedPreferences.getInstance();
  final encoded = jsonEncode(siteInfo.toJson());
  await preferences.setString(_siteInfoStorageKey, encoded);
}

/// 读取本地缓存的站点配置（无则 `null`）。
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

/// 是否具备「导出报价」插件能力（读本地站点缓存）。
Future<bool> readExportQuotationCapabilityFromLocal() async {
  return readBusinessPluginCapabilityFromLocal(
    pluginKey: BusinessPluginKeys.exportQuotation,
  );
}

/// 根据 [pluginKey] 判断本地站点是否启用对应业务插件。
Future<bool> readBusinessPluginCapabilityFromLocal({
  required String pluginKey,
}) async {
  final siteInfo = await readSiteInfoFromLocal();
  return hasBusinessPlugin(
    pluginUniqids: siteInfo?.pluginUniqid,
    pluginKey: pluginKey,
  );
}

/// 移除本地站点缓存。
Future<void> clearSiteInfoFromLocal() async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(_siteInfoStorageKey);
}

/// 基于已解析的 [SiteInfoDto] 判断是否支持导出报价。
bool hasExportQuotationCapability(SiteInfoDto siteInfo) {
  return hasBusinessPlugin(
    pluginUniqids: siteInfo.pluginUniqid,
    pluginKey: BusinessPluginKeys.exportQuotation,
  );
}
