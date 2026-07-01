import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/auth/api/store_company_requests.dart';
import 'package:george_pick_mate/shared/l10n/app_localizations_accessor.dart';

/// 拉取可选门店/站点列表（开放接口，无 DTO，条目为 `Map`）。
///
/// 期望解包后的 `result`：`{ items: [ { id, title, domain }, ... ], total }`。
Future<ApiResult<List<Map<String, dynamic>>>> fetchStoreCompanyItemsService({
  DioClient? client,
}) async {
  try {
    final response = await requestStoreCompanyList(client: client);
    final dynamic body = response.data;
    if (body is! Map) {
      return ApiFailure(
        AppException(appL10n.errorInvalidCompanyListResponse),
      );
    }
    final map = Map<String, dynamic>.from(body);
    final dynamic result = map['result'];
    final dynamic payload = result is Map ? Map<String, dynamic>.from(result) : map;
    final dynamic itemsRaw = payload['items'];
    if (itemsRaw is! List) {
      return ApiFailure(AppException(appL10n.errorMissingItemsInCompanyList));
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
        e.message ?? appL10n.errorFetchCompanyListFailed,
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
