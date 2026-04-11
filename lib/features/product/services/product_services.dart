import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/result/api_result.dart';
import 'package:groe_app_pad/core/result/app_exception.dart';
import 'package:groe_app_pad/features/product/api/product_requests.dart';
import 'package:groe_app_pad/features/product/models/product_item.dart';
import 'package:groe_app_pad/features/product/models/product_dto.dart';

import '../../../core/platform_services/network_clients.dart';

Future<ApiResult<List<ProductItem>>> fetchProductsPageService({
  required int page,
  required int pageSize,
}) async {
  final companyId = await secureStorageService.getCompanyId();
  try {
    final response = await requestProductsPage(page: page, pageSize: pageSize, companyId: companyId);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid product response format',
      );
    }
    final list = data['items'];
    if (list is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid products list format',
      );
    }
    final dtos = list
        .whereType<Map>()
        .map((e) => ProductDto.fromJson(Map<String, dynamic>.from(e)))
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

Future<ApiResult<ProductItem>> fetchProductByIdService(int id) async {
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

Future<ApiResult<void>> createFavorService({
  required int productId,
}) async {
  final companyId = await secureStorageService.getCompanyId();
  if (companyId == null || companyId.isEmpty) {
    return ApiFailure(
      const AppException('Missing company id'),
    );
  }
  try {
    var result = await createFavorRequest(
      productId: productId.toString(),
      companyId: companyId,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Create favorite failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<void>> deleteFavorService({
  required int productId,
}) async {
  final companyId = await secureStorageService.getCompanyId();
  if (companyId == null || companyId.isEmpty) {
    return ApiFailure(
      const AppException('Missing company id'),
    );
  }
  try {
    await deleteFavorRequest(
      productId: productId.toString(),
      companyId: companyId,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Delete favorite failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}
