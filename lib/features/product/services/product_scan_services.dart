import 'package:flutter/foundation.dart';
import 'package:george_pick_mate/core/network/store_host_controller.dart';

sealed class ProductScanResolveResult {
  const ProductScanResolveResult({required this.forwardedHost});

  final String forwardedHost;
}

final class ProductScanResolveProductId extends ProductScanResolveResult {
  const ProductScanResolveProductId({
    required this.productId,
    required super.forwardedHost,
  });

  final int productId;
}

final class ProductScanResolveUniqids extends ProductScanResolveResult {
  const ProductScanResolveUniqids({
    required this.uniqids,
    required super.forwardedHost,
  });

  final List<String> uniqids;
}

abstract final class ProductScanServices {
  static const String _prefix = 'url,';
  static const String _searchPathSegment = 'search';

  static ProductScanResolveResult? resolveFromScan(String rawCode) {
    final forwardedHost = extractForwardedHostFromScanUrl(rawCode);
    if (forwardedHost == null || forwardedHost.isEmpty) return null;

    final uniqids = resolveUniqidsFromScan(rawCode);
    if (uniqids != null && uniqids.isNotEmpty) {
      return ProductScanResolveUniqids(
        uniqids: uniqids,
        forwardedHost: forwardedHost,
      );
    }
    final productId = resolveProductIdFromScan(rawCode);
    if (productId != null) {
      return ProductScanResolveProductId(
        productId: productId,
        forwardedHost: forwardedHost,
      );
    }
    return null;
  }

  static List<String>? resolveUniqidsFromScan(String rawCode) {
    final normalized = rawCode.trim();
    if (normalized.isEmpty) return null;

    final payload = _extractUrlPayload(normalized);
    if (payload == null) return null;

    final uri = Uri.tryParse(payload);
    if (uri == null) return null;

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    if (!isHttp) return null;

    if (!_looksLikeSearch(uri)) return null;

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

  static bool _looksLikeSearch(Uri uri) {
    if (_pathEndsWithSearch(uri.path)) return true;

    final fragment = uri.fragment.trim();
    if (fragment.isEmpty) return false;

    final fragmentPath = fragment.split('?').first;
    return _pathEndsWithSearch(fragmentPath);
  }

  static bool _pathEndsWithSearch(String path) {
    final segments = _nonEmptyPathSegments(path);
    if (segments.isEmpty) return false;
    return segments.last.toLowerCase() == _searchPathSegment;
  }

  static List<String> _nonEmptyPathSegments(String path) {
    final normalized = path.trim();
    if (normalized.isEmpty) return const [];

    final withSlash = normalized.startsWith('/') ? normalized : '/$normalized';
    return Uri.parse('https://local.invalid$withSlash')
        .pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
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
