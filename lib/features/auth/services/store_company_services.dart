import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/api/store_company_requests.dart';
import 'package:george_pick_mate/features/auth/models/user_info_bean.dart';
import 'package:george_pick_mate/features/auth/services/auth_session_snapshot_services.dart';
import 'package:george_pick_mate/features/auth/services/site_info_services.dart';

// 门店列表与切换店铺：开放列表解析、切换后会话落盘。

/// 拉取可选门店/站点列表（开放接口，无 DTO，条目为 `Map`）。
///
/// 期望解包后的 `result`：`{ items: [ { id, title }, ... ], total }`。
Future<ApiResult<List<Map<String, dynamic>>>> fetchStoreCompanyItemsService({
  DioClient? client,
}) async {
  try {
    final response = await requestStoreCompanyList(client: client);
    final dynamic body = response.data;
    if (body is! Map) {
      return ApiFailure(
        AppException('Invalid company list response'),
      );
    }
    final map = Map<String, dynamic>.from(body);
    final dynamic itemsRaw = map['items'];
    if (itemsRaw is! List) {
      return ApiFailure(AppException('Missing items in company list'));
    }
    final out = <Map<String, dynamic>>[];
    for (final dynamic e in itemsRaw) {
      if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }
    return ApiSuccess(out);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch company list failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 切换店铺并落盘会话相关数据（与登录成功后的处理对齐）。
///
/// [companyId] / [shopId]：接口必填，通常均为所选行的 `id`。
/// 成功后顺序：[UserInfoBase] 持久化 → `companyId` → `tokenMap` 当前站点
/// token → [syncSiteInfoToLocal] 拉取并缓存站点配置。
Future<ApiResult<UserInfoBase>> switchShopService({
  required int companyId,
  required int shopId,
  DioClient? client,
}) async {
  try {
    final response = await requestSwitchShop(
      companyId: companyId,
      shopId: shopId,
      client: client,
    );
    final dynamic data = response.data;
    if (data is! Map) {
      return ApiFailure(
        AppException('Invalid switch shop response'),
      );
    }
    final user = UserInfoBase.fromJson(Map<String, dynamic>.from(data));
    final resolvedCompanyId = user.companyId?.toInt();
    final token = user.token?.toString();
    if (resolvedCompanyId == null) {
      return ApiFailure(
        AppException('Missing company_id in switch response'),
      );
    }
    if (token == null || token.isEmpty) {
      return ApiFailure(
        AppException('Missing token in switch response'),
      );
    }
    await persistAuthenticatedUserSnapshot(user);
    return ApiSuccess(user);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Switch shop failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
