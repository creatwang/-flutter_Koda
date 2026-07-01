import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/core/network/request_extras.dart';

void main() {
  group('mergeRequestOptions', () {
    test('returns base options when forwardedHost is null', () {
      final base = Options(extra: <String, dynamic>{'noCache': true});
      final merged = mergeRequestOptions(base: base, forwardedHost: null);

      expect(merged.extra?['noCache'], true);
      expect(merged.extra?.containsKey(RequestExtras.forwardedHost), false);
    });

    test('merges forwardedHost into extra', () {
      final merged = mergeRequestOptions(
        forwardedHost: 'ceramics.georgebuilder.com',
      );

      expect(
        merged.extra?[RequestExtras.forwardedHost],
        'ceramics.georgebuilder.com',
      );
    });

    test('preserves existing extra keys', () {
      final merged = mergeRequestOptions(
        base: Options(extra: <String, dynamic>{'noCache': true}),
        forwardedHost: 'shop.example.com',
      );

      expect(merged.extra?['noCache'], true);
      expect(merged.extra?[RequestExtras.forwardedHost], 'shop.example.com');
    });

    test('ignores blank forwardedHost', () {
      final merged = mergeRequestOptions(forwardedHost: '   ');

      expect(merged.extra?[RequestExtras.forwardedHost], isNull);
    });
  });
}
