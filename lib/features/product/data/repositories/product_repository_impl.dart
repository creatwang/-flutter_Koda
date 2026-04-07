import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/product/data/data_sources/product_remote_data_source.dart';
import 'package:groe_app_pad/features/product/data/models/product_dto.dart';
import 'package:groe_app_pad/features/product/domain/entities/product.dart';
import 'package:groe_app_pad/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<Product>>> fetchProductsPage({
    required int page,
    required int pageSize,
  }) async {
    try {
      final dtos = await _remoteDataSource.fetchProductsPage(
        page: page,
        pageSize: pageSize,
      );
      final entities = dtos.map((e) => e.toDomain()).toList(growable: false);
      return ApiSuccess(entities);
    } on DioException catch (e) {
      return ApiFailure(
        AppException(
          e.message ?? 'Fetch products failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      return ApiFailure(AppException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Product>> fetchProductById(int id) async {
    try {
      final dto = await _remoteDataSource.fetchProductById(id);
      return ApiSuccess(dto.toDomain());
    } on DioException catch (e) {
      return ApiFailure(
        AppException(
          e.message ?? 'Fetch product detail failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      return ApiFailure(AppException(e.toString()));
    }
  }
}
