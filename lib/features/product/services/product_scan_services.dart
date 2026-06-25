import 'package:flutter/foundation.dart';

/// 扫码解析结果。
sealed class ProductScanResolveResult {
  const ProductScanResolveResult();
}

/// 商品详情 id 扫码结果。
final class ProductScanResolveProductId extends ProductScanResolveResult {
  const ProductScanResolveProductId(this.productId);

  final int productId;
}

/// uniqids 组合扫码结果。
final class ProductScanResolveUniqids extends ProductScanResolveResult {
  const ProductScanResolveUniqids(this.uniqids);

  final List<String> uniqids;
}

/// 商品扫码解析（仅解析，不做 UI/网络）。
abstract final class ProductScanServices {
  static const String _prefix = 'url,';
  static const String _searchPathSegment = 'search';

  /// 解析扫码字符串，优先识别 uniqids 组合链接，其次识别商品详情 id。
  static ProductScanResolveResult? resolveFromScan(String rawCode) {
    final uniqids = resolveUniqidsFromScan(rawCode);
    if (uniqids != null && uniqids.isNotEmpty) {
      return ProductScanResolveUniqids(uniqids);
    }
    final productId = resolveProductIdFromScan(rawCode);
    if (productId != null) {
      return ProductScanResolveProductId(productId);
    }
    return null;
  }

  /// 解析 uniqids 组合链接。
  ///
  /// 支持格式示例：
  /// - `https://ceramics.georgebuilder.com/search?uniqids=ECO-FSL-243-01&uniqids=ECO-FSL-197-01`
  /// - `url,https://ceramics.georgebuilder.com/search?uniqids=ECO-FSL-243-01`
  static List<String>? resolveUniqidsFromScan(String rawCode) {
    final normalized = rawCode.trim();
    if (normalized.isEmpty) return null;

    final payload = _extractUrlPayload(normalized);
    if (payload == null) return null;

    final uri = Uri.tryParse(payload);
    if (uri == null) return null;

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    if (!isHttp) return null;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    final lastSegment = segments.last.toLowerCase();
    if (lastSegment != _searchPathSegment) return null;

    final uniqids = _extractUniqidsFromUri(uri);
    return uniqids.isEmpty ? null : uniqids;
  }

  static List<String> _extractUniqidsFromUri(Uri uri) {
    final fromQuery = uri.queryParametersAll['uniqids'] ?? const <String>[];
    if (fromQuery.isNotEmpty) {
      return fromQuery
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }

    final fromFragment = _uniqidsFromFragmentQuery(uri.fragment);
    if (fromFragment.isNotEmpty) return fromFragment;

    return const <String>[];
  }

  static List<String> _uniqidsFromFragmentQuery(String fragment) {
    final normalized = fragment.trim();
    if (normalized.isEmpty) return const <String>[];

    final queryStart = normalized.indexOf('?');
    if (queryStart == -1 || queryStart >= normalized.length - 1) {
      return const <String>[];
    }

    final queryText = normalized.substring(queryStart + 1);
    final synthetic = Uri.tryParse('https://local.invalid/?$queryText');
    if (synthetic == null) return const <String>[];

    return (synthetic.queryParametersAll['uniqids'] ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  /// 解析扫码字符串中的商品 id。
  ///
  /// 支持格式示例：
  /// - `url,https://.../goods-detail?id=64522`
  /// - `https://.../goods-detail?id=64522`（无 `url,` 前缀的裸链接）
  static int? resolveProductIdFromScan(String rawCode) {
    final normalized = rawCode.trim();
    if (normalized.isEmpty) return null;

    final payload = _extractUrlPayload(normalized);
    if (payload == null) return null;

    final uri = Uri.tryParse(payload);
    if (uri == null) return null;

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    if (!isHttp) return null;

    if (!_looksLikeGoodsDetail(uri)) return null;

    final queryId = _positiveIntOrNull(uri.queryParameters['id']);
    if (queryId != null) return queryId;

    final fragmentId = _idFromFragmentQuery(uri.fragment);
    if (fragmentId != null) return fragmentId;

    final fallback = RegExp(r'(?:^|[?&])id=(\d+)').firstMatch(payload);
    return _positiveIntOrNull(fallback?.group(1));
  }

  static String? _extractUrlPayload(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();
    if (lower.startsWith(_prefix)) {
      final payload = trimmed.substring(_prefix.length).trim();
      return payload.isEmpty ? null : payload;
    }
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }
    return null;
  }

  static bool _looksLikeGoodsDetail(Uri uri) {
    final aggregate = '${uri.path}?${uri.query}#${uri.fragment}'.toLowerCase();
    return aggregate.contains('goods-detail');
  }

  static int? _idFromFragmentQuery(String fragment) {
    final normalized = fragment.trim();
    if (normalized.isEmpty) return null;
    final queryStart = normalized.indexOf('?');
    if (queryStart == -1 || queryStart >= normalized.length - 1) {
      return null;
    }
    final queryText = normalized.substring(queryStart + 1);
    try {
      final params = Uri.splitQueryString(queryText);
      return _positiveIntOrNull(params['id']);
    } on FormatException catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      return null;
    }
  }

  static int? _positiveIntOrNull(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }
}
