import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/features/order/data/models/order_dto.dart';
import 'package:groe_app_pad/features/order/domain/entities/order_create_item.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<OrderDto>> fetchOrders({required int limit}) async {
    final response = await _dioClient.get(
      '/carts',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(OrderDto.fromJson)
          .toList(growable: false);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Invalid order response format',
    );
  }

  Future<OrderDto> createOrder({
    required int userId,
    required List<OrderCreateItem> items,
  }) async {
    final response = await _dioClient.post(
      '/carts',
      data: {
        'userId': userId,
        'date': DateTime.now().toUtc().toIso8601String(),
        'products': items
            .map((e) => {'productId': e.productId, 'quantity': e.quantity})
            .toList(growable: false),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return OrderDto.fromJson(data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Invalid create order response format',
    );
  }
}
