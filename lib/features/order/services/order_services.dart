import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/order/api/order_requests.dart';
import 'package:groe_app_pad/features/order/models/order_create_item.dart';
import 'package:groe_app_pad/features/order/models/order_dto.dart';
import 'package:groe_app_pad/features/order/models/order_summary.dart';

Future<ApiResult<List<OrderSummary>>> fetchOrdersService({
  required int limit,
}) async {
  try {
    final response = await requestOrders(limit: limit);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid order response format',
      );
    }
    final list = data['carts'];
    if (list is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid carts list format',
      );
    }
    final orders = list
        .whereType<Map<String, dynamic>>()
        .map(OrderDto.fromJson)
        .map((e) => e.toModel())
        .toList(growable: false);
    return ApiSuccess(orders);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch orders failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<OrderSummary>> createOrderService({
  required int userId,
  required List<OrderCreateItem> items,
}) async {
  try {
    final response = await requestCreateOrder(userId: userId, items: items);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid create order response format',
      );
    }
    final order = OrderDto.fromJson(data).toModel();
    return ApiSuccess(order);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Create order failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

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
