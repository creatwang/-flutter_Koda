import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/features/auth/services/store_company_services.dart';

/// 可选门店/站点列表（开放接口 [fetchStoreCompanyItemsService]），
/// [Ref.invalidate] 可在切换成功后刷新。
///
/// 每条为原始 `Map`（至少含 `id`、`title`），不做 DTO 映射。
final storeCompanyListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  Ref ref,
) async {
  final result = await fetchStoreCompanyItemsService();
  return result.when(
    success: (List<Map<String, dynamic>> items) => items,
    failure: (exception) => throw exception,
  );
});
