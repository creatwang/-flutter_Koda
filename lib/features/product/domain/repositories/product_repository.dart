import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/features/product/domain/entities/product.dart';

abstract interface class ProductRepository {
  Future<ApiResult<List<Product>>> fetchProductsPage({
    required int page,
    required int pageSize,
  });

  Future<ApiResult<Product>> fetchProductById(int id);
}
