import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/features/auth/services/auth_services.dart';

class ProductRequests {
  static const String productsPath = '/products';
}

Future<Response<dynamic>> requestProductsPage({
  required int page,
  required int pageSize,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.productsPath,
    queryParameters: {'limit': page * pageSize},
  );
}

Future<Response<dynamic>> requestProductById(
  int id, {
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get('${ProductRequests.productsPath}/$id');
}
