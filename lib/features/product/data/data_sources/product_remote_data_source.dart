import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/dio_client.dart';
import 'package:groe_app_pad/features/product/data/models/product_dto.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<ProductDto>> fetchProductsPage({
    required int page,
    required int pageSize,
  }) async {
    final response = await _dioClient.get(
      '/products',
      queryParameters: {'limit': page * pageSize},
    );
    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ProductDto.fromJson)
          .toList(growable: false);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Invalid product response format',
    );
  }

  Future<ProductDto> fetchProductById(int id) async {
    final response = await _dioClient.get('/products/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ProductDto.fromJson(data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Invalid product detail response format',
    );
  }
}
