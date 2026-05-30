import 'package:flutter/foundation.dart';

/// 商品扫码解析（仅解析，不做 UI/网络）。
abstract final class ProductScanServices {
  static const String _prefix = 'url,';

  /// 解析扫码字符串中的商品 id。
  ///
  /// 支持格式示例：
  /// `url,https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail?id=64522`
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
    final lower = value.toLowerCase();
    if (!lower.startsWith(_prefix)) return null;
    final payload = value.substring(_prefix.length).trim();
    return payload.isEmpty ? null : payload;
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
