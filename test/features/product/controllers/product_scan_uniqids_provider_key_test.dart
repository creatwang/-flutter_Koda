import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/features/product/controllers/product_scan_uniqids_providers.dart';

void main() {
  group('scan uniqids provider key', () {
    test('encode without scanHost keeps uniqids only', () {
      final key = encodeScanUniqidsProviderKey(['A', 'B']);

      expect(decodeScanUniqidsProviderKey(key), ['A', 'B']);
      expect(decodeScanHostFromProviderKey(key), isNull);
    });

    test('encode with scanHost prefixes host', () {
      const host = 'ceramics.georgebuilder.com';
      final key = encodeScanUniqidsProviderKey(['A'], scanHost: host);

      expect(decodeScanHostFromProviderKey(key), host);
      expect(decodeScanUniqidsProviderKey(key), ['A']);
    });
  });
}
