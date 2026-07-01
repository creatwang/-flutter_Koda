import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/core/network/store_host_routing.dart';

void main() {
  const storeApiBaseUrl = 'https://ceramics.example.com/testapi';

  group('resolveRequestBaseUrl', () {
    test('uses store api base url on all platforms', () {
      expect(
        resolveRequestBaseUrl(storeApiBaseUrl: storeApiBaseUrl),
        storeApiBaseUrl,
      );
    });
  });

  group('resolveSessionForwardedHost', () {
    test('always returns null', () {
      expect(
        resolveSessionForwardedHost(storeHost: 'ceramics.example.com'),
        isNull,
      );
    });
  });

  group('resolveRequestForwardedHost', () {
    test('returns explicit scan host when provided', () {
      expect(
        resolveRequestForwardedHost(
          explicitForwardedHost: 'scan.example.com',
          storeHost: 'ceramics.example.com',
        ),
        'scan.example.com',
      );
    });

    test('returns null without explicit scan host', () {
      expect(
        resolveRequestForwardedHost(
          explicitForwardedHost: null,
          storeHost: 'ceramics.example.com',
        ),
        isNull,
      );
    });
  });
}
