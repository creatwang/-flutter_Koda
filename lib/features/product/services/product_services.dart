import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/product/api/product_requests.dart';
import 'package:groe_app_pad/features/product/models/product.dart';
import 'package:groe_app_pad/features/product/models/product_dto.dart';

Future<ApiResult<List<Product>>> fetchProductsPageService({
  required int page,
  required int pageSize,
}) async {
  try {
    final response = await requestProductsPage(page: page, pageSize: pageSize);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid product response format',
      );
    }
    final list = data['products'];
    if (list is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid products list format',
      );
    }
    final dtos = list
        .whereType<Map<String, dynamic>>()
        .map(ProductDto.fromJson)
        .toList(growable: false);
    return ApiSuccess(dtos.map((e) => e.toModel()).toList(growable: false));
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

Future<ApiResult<Product>> fetchProductByIdService(int id) async {
  try {
    final response = await requestProductById(id);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid product detail response format',
      );
    }
    return ApiSuccess(ProductDto.fromJson(data).toModel());
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
