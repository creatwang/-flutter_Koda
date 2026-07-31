import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:george_pick_mate/features/product/models/paginated_products_state.dart';
import 'package:george_pick_mate/features/product/services/product_services.dart';

const String _uniqidsProviderKeySeparator = '\x1f';
const String _scanHostKeySeparator = '\x1e';
const String _qrcodeKeyMarker = '\x1dqk:';

String encodeScanUniqidsProviderKey(
  List<String> uniqids, {
  String? scanHost,
  String? qrcodeKey,
}) {
  final host = scanHost?.trim();
  final normalizedQrcodeKey = qrcodeKey?.trim();
  final String payload;
  if (normalizedQrcodeKey != null && normalizedQrcodeKey.isNotEmpty) {
    payload = '$_qrcodeKeyMarker$normalizedQrcodeKey';
  } else {
    payload = uniqids.join(_uniqidsProviderKeySeparator);
  }
  if (host == null || host.isEmpty) return payload;
  return '$host$_scanHostKeySeparator$payload';
}

String _payloadFromProviderKey(String key) {
  if (!key.contains(_scanHostKeySeparator)) return key;
  return key.split(_scanHostKeySeparator).skip(1).join(_scanHostKeySeparator);
}

List<String> decodeScanUniqidsProviderKey(String key) {
  final uniqidsPart = _payloadFromProviderKey(key);
  if (uniqidsPart.startsWith(_qrcodeKeyMarker)) return const <String>[];
  return uniqidsPart
      .split(_uniqidsProviderKeySeparator)
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

String? decodeScanHostFromProviderKey(String key) {
  if (!key.contains(_scanHostKeySeparator)) return null;
  final host = key.split(_scanHostKeySeparator).first.trim();
  return host.isEmpty ? null : host;
}

String? decodeScanQrcodeKeyFromProviderKey(String key) {
  final payload = _payloadFromProviderKey(key);
  if (!payload.startsWith(_qrcodeKeyMarker)) return null;
  final value = payload.substring(_qrcodeKeyMarker.length).trim();
  return value.isEmpty ? null : value;
}

final scanUniqidsProductsProvider = AsyncNotifierProvider.autoDispose
    .family<ScanUniqidsProductsNotifier, PaginatedProductsState, String>(
      ScanUniqidsProductsNotifier.new,
    );

class ScanUniqidsProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  ScanUniqidsProductsNotifier(this._providerKey);

  final String _providerKey;
  static const int _pageSize = 8;
  int _queryVersion = 0;

  List<String> get _uniqids => decodeScanUniqidsProviderKey(_providerKey);

  String? get _scanHost => decodeScanHostFromProviderKey(_providerKey);

  String? get _qrcodeKey => decodeScanQrcodeKeyFromProviderKey(_providerKey);

  bool get _hasQuery =>
      _uniqids.isNotEmpty ||
      (_qrcodeKey != null && _qrcodeKey!.isNotEmpty);

  @override
  FutureOr<PaginatedProductsState> build() async {
    _queryVersion++;
    if (!_hasQuery) {
      return const PaginatedProductsState(items: [], page: 1, hasMore: false);
    }
    final result = await fetchProductsPageService(
      page: 1,
      pageSize: _pageSize,
      uniqids: _uniqids.isEmpty ? null : _uniqids,
      qrcodeKey: _qrcodeKey,
      forwardedHost: _scanHost,
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
      if (!_hasQuery) {
        return const PaginatedProductsState(items: [], page: 1, hasMore: false);
      }
      final result = await fetchProductsPageService(
        page: 1,
        pageSize: _pageSize,
        uniqids: _uniqids.isEmpty ? null : _uniqids,
        qrcodeKey: _qrcodeKey,
        forwardedHost: _scanHost,
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
        !_hasQuery) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final version = _queryVersion;
    final result = await fetchProductsPageService(
      page: nextPage,
      pageSize: _pageSize,
      uniqids: _uniqids.isEmpty ? null : _uniqids,
      qrcodeKey: _qrcodeKey,
      forwardedHost: _scanHost,
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
