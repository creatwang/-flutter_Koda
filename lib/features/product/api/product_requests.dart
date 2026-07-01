import 'package:dio/dio.dart';
import 'package:george_pick_mate/core/network/dio_client.dart';
import 'package:george_pick_mate/core/network/interceptors/response_data_mode_interceptor.dart';
import 'package:george_pick_mate/core/network/request_extras.dart';
import 'package:george_pick_mate/core/platform_services/network_clients.dart';

class ProductRequests {
  ProductRequests._();

  static const String productsPath = '/store/product/lists';
  static const String showroomSampleFilterQueryKey =
      'params[展厅是否有样板/Is there a sample in the exhibition hall]';
  static const String createFavorPath = '/store/collect/create';
  static const String deleteFavorPath = '/store/collect/delete';
  static const String getCategoryTree = '/store/category/tree';
  static const String getProductDetail = '/store/product/detail';
  static const String getFavorPageList = '/store/collect/getPageList';
}

Future<Response<dynamic>> requestProductDetail({
  required int id,
  String? forwardedHost,
  DioClient? client,
}) {
  return (client ?? publicDioClient).get(
    ProductRequests.getProductDetail,
    options: mergeRequestOptions(
      base: Options(
        extra: <String, dynamic>{
          ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey: true,
        },
      ),
      forwardedHost: forwardedHost,
    ),
    queryParameters: <String, dynamic>{'id': id, 'apiType': 'store'},
  );
}

Future<Response<dynamic>> requestProductsPage({
  required int page,
  required int pageSize,
  int shopCateGoryId = 0,
  String? sort,
  int orderBy = 0,
  bool onlyShowroomSample = false,
  String? keyword,
  List<String>? uniqids,
  String? forwardedHost,
  DioClient? client,
}) {
  final queryParameters = <String, dynamic>{
    'shop_category_id': shopCateGoryId,
    'order_by': orderBy,
    if (sort != null) 'sort': sort,
    'page_size': pageSize,
    'page': page,
    if (onlyShowroomSample)
      ProductRequests.showroomSampleFilterQueryKey: '是',
    if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    if (uniqids != null && uniqids.isNotEmpty) 'uniqids': uniqids,
  };

  return (client ?? protectedDioClient).get(
    ProductRequests.productsPath,
    queryParameters: queryParameters,
    options: mergeRequestOptions(
      base: uniqids != null && uniqids.isNotEmpty
          ? Options(listFormat: ListFormat.multiCompatible)
          : null,
      forwardedHost: forwardedHost,
    ),
  );
}

Future<Response<dynamic>> requestFavorPageList({
  required int page,
  required int pageSize,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.getFavorPageList,
    queryParameters: <String, dynamic>{
      'page': page,
      'pag_size': pageSize,
    },
  );
}

Future<Response<dynamic>> requestCategoryTree({DioClient? client}) {
  return (client ?? protectedDioClient).get(
    ProductRequests.getCategoryTree,
  );
}

Future<Response<dynamic>> requestProductById(
  int id, {
  DioClient? client,
}) {
  return (client ?? protectedDioClient).get(
    '${ProductRequests.productsPath}/$id',
  );
}

Future<Response<dynamic>> createFavorRequest({
  required String productId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    ProductRequests.createFavorPath,
    options: Options(
      extra: <String, dynamic>{
        'noCache': true,
        'noRetry': true,
      },
    ),
    queryParameters: <String, dynamic>{'product_id': productId},
  );
}

Future<Response<dynamic>> deleteFavorRequest({
  required String productId,
  DioClient? client,
}) {
  return (client ?? protectedDioClient).post(
    ProductRequests.deleteFavorPath,
    options: Options(
      extra: <String, dynamic>{
        'noCache': true,
        'noRetry': true,
      },
    ),
    queryParameters: <String, dynamic>{'product_id': productId},
  );
}
