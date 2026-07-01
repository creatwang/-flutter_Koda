import 'package:flutter_test/flutter_test.dart';
import 'package:george_pick_mate/features/product/controllers/product_detail_request_key.dart';

void main() {
  group('product detail provider key', () {
    test('encode without scanHost returns product id only', () {
      expect(
        encodeProductDetailProviderKey(productId: 64522),
        '64522',
      );
    });

    test('encode with scanHost joins with separator', () {
      final key = encodeProductDetailProviderKey(
        productId: 64522,
        scanHost: 'ceramics.georgebuilder.com',
      );

      expect(key, contains('64522'));
      expect(key, contains('ceramics.georgebuilder.com'));
    });

    test('decode round-trips with scanHost', () {
      const host = 'ceramics.georgebuilder.com';
      final key = encodeProductDetailProviderKey(
        productId: 99,
        scanHost: host,
      );

      final decoded = decodeProductDetailProviderKey(key);

      expect(decoded.productId, 99);
      expect(decoded.scanHost, host);
    });

    test('decode without scanHost returns null scanHost', () {
      final decoded = decodeProductDetailProviderKey('123');

      expect(decoded.productId, 123);
      expect(decoded.scanHost, isNull);
    });
  });
}
