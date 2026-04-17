import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/order/api/order_requests.dart';

Future<ApiResult<void>> createOrderBySitesService({
  required List<int> companyIds,
  required List<Map<String, dynamic>> cart,
}) async {
  try {
    await requestCreateOrderBySites(companyIds: companyIds, cart: cart);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Create order by sites failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
