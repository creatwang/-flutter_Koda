import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/features/order/models/order_create_item.dart';

import '../../../core/services/core_services.dart';

class OrderRequests {
  static const String cartsPath = '/carts';
}

Future<Response<dynamic>> requestOrders({
  required int limit,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    OrderRequests.cartsPath,
    queryParameters: {'limit': limit},
  );
}

Future<Response<dynamic>> requestCreateOrder({
  required int userId,
  required List<OrderCreateItem> items,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    OrderRequests.cartsPath,
    data: {
      'userId': userId,
      'date': DateTime.now().toUtc().toIso8601String(),
      'products': items
          .map((e) => {'productId': e.productId, 'quantity': e.quantity})
          .toList(growable: false),
    },
  );
}
