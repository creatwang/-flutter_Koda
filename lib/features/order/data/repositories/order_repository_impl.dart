import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/order/data/data_sources/order_remote_data_source.dart';
import 'package:groe_app_pad/features/order/data/models/order_dto.dart';
import 'package:groe_app_pad/features/order/domain/entities/order_create_item.dart';
import 'package:groe_app_pad/features/order/domain/entities/order_summary.dart';
import 'package:groe_app_pad/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remoteDataSource);

  final OrderRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<OrderSummary>>> fetchOrders({required int limit}) async {
    try {
      final orders = await _remoteDataSource.fetchOrders(limit: limit);
      return ApiSuccess(orders.map((e) => e.toDomain()).toList(growable: false));
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

  @override
  Future<ApiResult<OrderSummary>> createOrder({
    required int userId,
    required List<OrderCreateItem> items,
  }) async {
    try {
      final order = await _remoteDataSource.createOrder(userId: userId, items: items);
      return ApiSuccess(order.toDomain());
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
}
