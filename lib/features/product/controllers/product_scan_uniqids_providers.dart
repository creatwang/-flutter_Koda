import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/product/models/paginated_products_state.dart';
import 'package:george_pick_mate/features/product/services/product_services.dart';

const String _uniqidsProviderKeySeparator = '\x1f';

/// 将 uniqids 列表编码为 provider family 参数。
String encodeScanUniqidsProviderKey(List<String> uniqids) =>
    uniqids.join(_uniqidsProviderKeySeparator);

/// 将 provider family 参数解码为 uniqids 列表。
List<String> decodeScanUniqidsProviderKey(String key) => key
    .split(_uniqidsProviderKeySeparator)
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList(growable: false);

/// 扫码 uniqids 组合对应的商品分页列表。
final scanUniqidsProductsProvider = AsyncNotifierProvider.autoDispose
    .family<ScanUniqidsProductsNotifier, PaginatedProductsState, String>(
      ScanUniqidsProductsNotifier.new,
    );

class ScanUniqidsProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  ScanUniqidsProductsNotifier(this._uniqidsKey);

  final String _uniqidsKey;
  static const int _pageSize = 8;
  int _queryVersion = 0;

  List<String> get _uniqids => decodeScanUniqidsProviderKey(_uniqidsKey);

  @override
  FutureOr<PaginatedProductsState> build() async {
    _queryVersion++;
    if (_uniqids.isEmpty) {
      return const PaginatedProductsState(items: [], page: 1, hasMore: false);
    }
    final result = await fetchProductsPageService(
      page: 1,
      pageSize: _pageSize,
      uniqids: _uniqids,
    );
    return result.when(
      success: (data) => PaginatedProductsState(
        items: data,
        page: 1,
        hasMore: data.length >= _pageSize,
      ),
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    _queryVersion++;
    final version = _queryVersion;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (_uniqids.isEmpty) {
        return const PaginatedProductsState(items: [], page: 1, hasMore: false);
      }
      final result = await fetchProductsPageService(
        page: 1,
        pageSize: _pageSize,
        uniqids: _uniqids,
      );
      if (version != _queryVersion) {
        throw StateError('Stale scan uniqids refresh response');
      }
      return result.when(
        success: (data) => PaginatedProductsState(
          items: data,
          page: 1,
          hasMore: data.length >= _pageSize,
        ),
        failure: (exception) => throw exception,
      );
    });
  }

  Future<void> loadMoreOnScroll() => _loadMoreNextPage();

  Future<void> loadMoreWhenViewportNotFilled() => _loadMoreNextPage();

  Future<void> _loadMoreNextPage() async {
    final current = state.asData?.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        _uniqids.isEmpty) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final version = _queryVersion;
    final result = await fetchProductsPageService(
      page: nextPage,
      pageSize: _pageSize,
      uniqids: _uniqids,
    );
    if (version != _queryVersion) return;

    state = result.when(
      success: (allData) {
        final oldIds = current.items.map((e) => e.id).toSet();
        final delta = allData.where((e) => !oldIds.contains(e.id)).toList();
        final merged = [...current.items, ...delta];
        return AsyncData(
          current.copyWith(
            items: merged,
            page: nextPage,
            hasMore: delta.isNotEmpty && allData.length >= _pageSize,
            isLoadingMore: false,
          ),
        );
      },
      failure: (exception) => AsyncError(exception, StackTrace.current),
    );
  }
}
