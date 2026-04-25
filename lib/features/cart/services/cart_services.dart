import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:george_pick_mate/core/network/api_business_code.dart';
import 'package:george_pick_mate/core/result/api_result.dart';
import 'package:george_pick_mate/core/result/app_exception.dart';
import 'package:george_pick_mate/features/cart/api/cart_requests.dart';
import 'package:george_pick_mate/features/cart/models/cart_list_dto.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_config_dto.dart';
import 'package:george_pick_mate/features/cart/models/cart_quotation_export_result_dto.dart';
import 'package:path_provider/path_provider.dart';

/// 购物车网络结果解析与 [AppException] 映射（调用 `cart_requests`）。

/// `GET /store/cart/num` → `result.total_num`。
Future<ApiResult<int>> fetchCartTotalNumService() async {
  try {
    final response = await requestCartNum();
    final dynamic data = response.data;
    if (data is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid cart num response format',
      );
    }
    final map = Map<String, dynamic>.from(data);
    final code = map['code'];
    if (code is num && code != 0) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: map['message']?.toString() ?? 'Cart num request failed',
      );
    }
    if (code is String && code != '0' && code.trim() != '0') {
      throw DioException(
        requestOptions: response.requestOptions,
        message: map['message']?.toString() ?? 'Cart num request failed',
      );
    }
    final dynamic resultNode = map['result'];
    if (resultNode is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Missing result in cart num response',
      );
    }
    final resultMap = Map<String, dynamic>.from(resultNode);
    final dynamic raw = resultMap['total_num'];
    final int total = raw is int
        ? raw
        : (raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '') ?? 0);
    return ApiSuccess(total);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch cart num failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Future<ApiResult<List<CartListDto>>> fetchCartListBySiteService({
  int? smStatus = 0,
}) async {
  try {
    final response = await requestCartListBySite(
      smStatus: smStatus,
    );
    final data = response.data;
    final rawList = switch (data) {
      List() => data,
      Map() => data['result'] is List ? data['result'] as List : null,
      _ => null,
    };
    if (rawList == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid cart list response format',
      );
    }
    final cartList = rawList
        .whereType<Map>()
        .map((e) => CartListDto.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    return ApiSuccess(cartList);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch cart list failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 批量更新购物车行选中态。
///
/// [ids]：行 id；[selected]：目标选中状态。
Future<ApiResult<void>> updateCartSelectedService({
  required List<int> ids,
  required bool selected,
}) async {
  try {
    await requestCartSelected(ids: ids, selected: selected ? 1 : 0);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Update cart selected failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 更新购物车行备注。
///
/// 错误提示由全局拦截器统一处理，此处只回传结果给调用方用于回滚。
Future<ApiResult<void>> updateCartRemarkService({
  required int id,
  required String remark,
}) async {
  try {
    await requestCartRemark(id: id, remark: remark);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Update remark failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 修改单行购买数量。
///
/// [id]：购物车行 id；[productNum]：新数量。
Future<ApiResult<void>> changeCartQuantityService({
  required int id,
  required int productNum,
}) async {
  try {
    await requestCartChangeQuantity(id: id, productNum: productNum);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Change cart quantity failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 删除购物车行。
///
/// [ids]：待删除行 id 列表。
Future<ApiResult<void>> removeCartItemsService({required List<int> ids}) async {
  try {
    await requestCartDelete(ids: ids);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Delete cart item failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 多站点合并下单。
///
/// [companyIds]：站点集合；[cart]：接口要求的购物车负载。
Future<ApiResult<void>> createOrderBySitesService({
  required List<int> companyIds,
  required List<Map<String, dynamic>> cart,
}) async {
  try {
    await requestCreateOrderBySites(companyIds: companyIds, cart: cart);
    return const ApiSuccess(null);
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

/// 按站点清空购物车。
///
/// [companyId]：站点 id。
Future<ApiResult<void>> clearCartBySiteService({required int companyId}) async {
  try {
    await requestCartClear(companyId: companyId);
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Clear cart failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 预提交前校验：存在已选商品的站点若返回了 SM 列表，则必须已选 SM。
///
/// [reportedSmIdByCompanyId] 由购物车页同步各站点当前选择的 `sm_id`
///（含用户刚选尚未落库的值）。
String? validateSmForPreSubmitOrder({
  required List<CartListDto> groups,
  required Map<int, int> reportedSmIdByCompanyId,
}) {
  for (final group in groups) {
    for (final site in group.items) {
      final hasSelected = site.cart.items
          .expand((sp) => sp.list)
          .any((p) => p.isSelected);
      if (!hasSelected) continue;
      final repList = site.smItems.isNotEmpty
          ? site.smItems
          : group.smItems;
      if (repList.isEmpty) continue;
      final fallbackSmId =
          site.smId > 0 ? site.smId : group.smId;
      final smId =
          reportedSmIdByCompanyId[site.companyId] ?? fallbackSmId;
      if (smId <= 0) {
        final fromSite = site.shopName.trim();
        final fromGroup = group.name.trim();
        final label = fromSite.isNotEmpty
            ? fromSite
            : (fromGroup.isNotEmpty ? fromGroup : 'Department');
        return 'Please select SM ($label)';
      }
    }
  }
  return null;
}

/// 组装 [requestCartSetSm] 请求体中的 `data`。
///
/// [shop_department_id] 为购物车列表一级 [CartListDto.id]；同一部门多站点时
/// 取迭代中最后一次有效 `sm_id`，并附带该部门下当前选中行 `cart_ids`。
List<Map<String, dynamic>> buildSetSmRequestItems({
  required List<CartListDto> groups,
  required Map<int, int> reportedSmIdByCompanyId,
}) {
  final departmentToSm = <int, int>{};
  final departmentToCartIds = <int, Set<int>>{};
  for (final group in groups) {
    for (final site in group.items) {
      final selectedItems = site.cart.items
          .expand((sp) => sp.list)
          .where((p) => p.isSelected)
          .toList(growable: false);
      final hasSelected = selectedItems.isNotEmpty;
      if (!hasSelected) continue;
      final repList = site.smItems.isNotEmpty
          ? site.smItems
          : group.smItems;
      if (repList.isEmpty) continue;
      final fallbackSmId =
          site.smId > 0 ? site.smId : group.smId;
      final smId =
          reportedSmIdByCompanyId[site.companyId] ?? fallbackSmId;
      if (smId <= 0) continue;
      departmentToSm[group.id] = smId;
      final cartIds = departmentToCartIds.putIfAbsent(
        group.id,
        () => <int>{},
      );
      cartIds.addAll(selectedItems.map((item) => item.id));
    }
  }
  return departmentToSm.entries
      .map(
        (e) => <String, dynamic>{
          'shop_department_id': e.key,
          'sm_id': e.value,
          'cart_ids': (departmentToCartIds[e.key] ?? const <int>{})
              .toList(growable: false),
        },
      )
      .toList(growable: false);
}

/// 调用 [requestCartSetSm] 写入 `data`（与预提交、预订单即时保存共用）。
Future<ApiResult<void>> postCartSetSm({
  required List<Map<String, dynamic>> items,
}) async {
  if (items.isEmpty) {
    return ApiFailure(
      AppException('No sales rep selections to submit.'),
    );
  }
  try {
    final response = await requestCartSetSm(data: items);
    final payload = response.data;
    if (payload is! Map) {
      return ApiFailure(
        AppException(
          'Set SM failed',
          code: response.statusCode?.toString(),
        ),
      );
    }
    final map = Map<String, dynamic>.from(payload);
    final code = map['code'];
    if (!isApiBusinessSuccessCode(code)) {
      return ApiFailure(
        AppException(
          map['message']?.toString() ?? 'Set SM failed',
          code: code?.toString(),
        ),
      );
    }
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Set SM failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 为单个部门写入 SM（与 [setCartSmForPreSubmitService] 同一接口）。
Future<ApiResult<void>> setCartSmForShopDepartmentService({
  required int shopDepartmentId,
  required int smId,
}) async {
  if (shopDepartmentId <= 0 || smId <= 0) {
    return ApiFailure(AppException('Invalid SM selection.'));
  }
  return postCartSetSm(
    items: <Map<String, dynamic>>[
      <String, dynamic>{
        'shop_department_id': shopDepartmentId,
        'sm_id': smId,
      },
    ],
  );
}

/// 预提交：调用 [requestCartSetSm] 写入各部门所选 SM。
Future<ApiResult<void>> setCartSmForPreSubmitService({
  required List<CartListDto> groups,
  required Map<int, int> reportedSmIdByCompanyId,
}) async {
  final items = buildSetSmRequestItems(
    groups: groups,
    reportedSmIdByCompanyId: reportedSmIdByCompanyId,
  );
  return postCartSetSm(items: items);
}

/// 加购。
///
/// 字段与后端 `create` 接口一致。
Future<ApiResult<void>> createCartItemService({
  required int productId,
  required String subIndex,
  required int productNum,
  required String space,
  required String subName,
}) async {
  try {
    final response = await requestCartCreate(
      productId: productId,
      subIndex: subIndex,
      productNum: productNum,
      space: space,
      subName: subName,
    );
    final payload = response.data;
    if (payload is! Map) {
      return ApiFailure(
        AppException(
          'Add to cart failed',
          code: response.statusCode?.toString(),
        ),
      );
    }
    final map = Map<String, dynamic>.from(payload);
    final code = map['code'];
    if (code is num && code == 100000) {
      return ApiFailure(
        AppException(
          'There are still unordered items in the shopping cart',
          code: code.toString(),
        ),
      );
    }
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Add to cart failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 购物车行改规格。
///
/// [id]：原行 id；其余同加购语义。
Future<ApiResult<void>> changeCartItemSpecService({
  required int id,
  required int productId,
  required String subIndex,
  required String space,
  required String subName,
}) async {
  try {
    await requestCartChangeSpec(
      id: id,
      productId: productId,
      subIndex: subIndex,
      space: space,
      subName: subName,
    );
    return const ApiSuccess(null);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Change cart spec failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 获取报价单导出弹窗配置。
Future<ApiResult<CartQuotationConfigDto>> fetchQuotationConfigService() async {
  try {
    final response = await requestQuotationConfig();
    final dynamic data = response.data;
    if (data is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid quotation config response format',
      );
    }
    final map = Map<String, dynamic>.from(data);
    final code = map['code'];
    if (code is num && code != 0) {
      throw DioException(
        requestOptions: response.requestOptions,
        message:
            map['message']?.toString() ?? 'Quotation config request failed',
      );
    }
    if (code is String && code != '0' && code.trim() != '0') {
      throw DioException(
        requestOptions: response.requestOptions,
        message:
            map['message']?.toString() ?? 'Quotation config request failed',
      );
    }
    final dynamic resultNode = map['result'];
    final resultMap = resultNode is Map
        ? Map<String, dynamic>.from(resultNode)
        : <String, dynamic>{};
    return ApiSuccess(CartQuotationConfigDto.fromJson(resultMap));
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Fetch quotation config failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 发送报价单导出请求并保存为本地 Excel 文件。
Future<ApiResult<CartQuotationExportResultDto>> exportQuotationService({
  required Map<String, dynamic> formData,
}) async {
  try {
    final response = await requestExportQuotation(formData: formData);
    final bytes = _extractBytes(response.data);
    if (bytes == null || bytes.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Export quotation response is empty',
      );
    }
    final contentType = _extractContentType(response);
    if (_looksLikeJsonResponse(contentType, bytes)) {
      final jsonMap = _parseJsonBytes(bytes);
      final message = _extractExportErrorMessage(jsonMap);
      throw DioException(
        requestOptions: response.requestOptions,
        message: message,
      );
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'quotation_$timestamp.xlsx';
    final directory = await _resolveExportDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return ApiSuccess(
      CartQuotationExportResultDto(fileName: fileName, filePath: file.path),
    );
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Export quotation failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

/// 预览报价单，返回可直接加载的 Office 在线预览 URL。
Future<ApiResult<String>> previewQuotationService({
  required Map<String, dynamic> formData,
}) async {
  try {
    final response = await requestExportQuotationPreview(formData: formData);
    final dynamic data = response.data;
    if (data is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Invalid preview response format',
      );
    }
    final map = Map<String, dynamic>.from(data);
    final code = map['code'];
    if (code is num && code != 0) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: _extractExportErrorMessage(map),
      );
    }
    if (code is String && code != '0' && code.trim() != '0') {
      throw DioException(
        requestOptions: response.requestOptions,
        message: _extractExportErrorMessage(map),
      );
    }
    final rawResult = map['result']?.toString().trim() ?? '';
    if (rawResult.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Preview url is empty',
      );
    }
    final previewUrl = _buildOfficePreviewUrl(rawResult);
    return ApiSuccess(previewUrl);
  } on DioException catch (e) {
    return ApiFailure(
      AppException(
        e.message ?? 'Preview quotation failed',
        code: e.response?.statusCode?.toString(),
      ),
    );
  } catch (e) {
    return ApiFailure(AppException(e.toString()));
  }
}

Uint8List? _extractBytes(dynamic data) {
  if (data is Uint8List) return data;
  if (data is List<int>) return Uint8List.fromList(data);
  if (data is List) {
    return Uint8List.fromList(data.whereType<int>().toList(growable: false));
  }
  if (data is String) return Uint8List.fromList(utf8.encode(data));
  return null;
}

String _extractContentType(Response<dynamic> response) {
  final value = response.headers.value(Headers.contentTypeHeader);
  if (value == null) return '';
  return value.toLowerCase();
}

bool _looksLikeJsonResponse(String contentType, Uint8List bytes) {
  if (contentType.contains('application/json') ||
      contentType.contains('text/json')) {
    return true;
  }
  if (bytes.isEmpty) return false;
  final first = bytes.first;
  return first == 123 || first == 91;
}

Map<String, dynamic> _parseJsonBytes(Uint8List bytes) {
  try {
    final text = utf8.decode(bytes);
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
  } catch (_) {
    return const <String, dynamic>{};
  }
  return const <String, dynamic>{};
}

String _extractExportErrorMessage(Map<String, dynamic> jsonMap) {
  final errMsgNode = jsonMap['errMsg'];
  if (errMsgNode is List) {
    final firstNonEmpty = errMsgNode
        .map((item) => item?.toString().trim() ?? '')
        .firstWhere((item) => item.isNotEmpty, orElse: () => '');
    if (firstNonEmpty.isNotEmpty) return firstNonEmpty;
  }
  final message = jsonMap['message']?.toString().trim() ?? '';
  if (message.isNotEmpty) return message;
  return 'Export quotation failed';
}

String _buildOfficePreviewUrl(String fileUrl) {
  final encoded = Uri.encodeComponent(fileUrl);
  return 'https://view.officeapps.live.com/op/view.aspx?src=$encoded';
}

Future<Directory> _resolveExportDirectory() async {
  if (!kIsWeb) {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      await downloads.create(recursive: true);
      return downloads;
    }
  }
  final documents = await getApplicationDocumentsDirectory();
  await documents.create(recursive: true);
  return documents;
}
