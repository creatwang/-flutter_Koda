import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/order/domain/entities/order_create_item.dart';
import 'package:groe_app_pad/features/order/domain/entities/order_summary.dart';

abstract interface class OrderRepository {
  Future<ApiResult<List<OrderSummary>>> fetchOrders({required int limit});

  Future<ApiResult<OrderSummary>> createOrder({
    required int userId,
    required List<OrderCreateItem> items,
  });
}
