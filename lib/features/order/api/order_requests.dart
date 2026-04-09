import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/features/order/models/order_create_item.dart';

import '../../../core/platform_services/network_clients.dart';

class OrderRequests {
  static const String cartsPath = '/carts';
  static const String cartsAddPath = '/carts/add';
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
    OrderRequests.cartsAddPath,
    data: {
      'userId': userId,
      'products': items
          .map((e) => {'id': e.productId, 'quantity': e.quantity})
          .toList(growable: false),
    },
  );
}
