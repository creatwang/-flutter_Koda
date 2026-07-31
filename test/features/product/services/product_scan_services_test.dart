import 'package:flutter_test/flutter_test.dart';

import 'package:george_pick_mate/features/product/services/product_scan_services.dart';



void main() {

  group('ProductScanServices.resolveProductIdFromScan', () {

    test('parses id from hash-route query', () {

      const code =

          'url,https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail?id=64522';



      final id = ProductScanServices.resolveProductIdFromScan(code);



      expect(id, 64522);

    });



    test('parses id from standard query', () {

      const code =

          'url,https://demo.gbuilderchina.com/pages/goods-detail/goods-detail?id=12345';



      final id = ProductScanServices.resolveProductIdFromScan(code);



      expect(id, 12345);

    });



    test('parses bare https url without url comma prefix', () {

      const code =

          'https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail?id=64521';



      final id = ProductScanServices.resolveProductIdFromScan(code);



      expect(id, 64521);

    });



    test('returns null when id is missing', () {

      const code =

          'url,https://demo.gbuilderchina.com/m/#/pages/goods-detail/goods-detail';



      final id = ProductScanServices.resolveProductIdFromScan(code);



      expect(id, isNull);

    });



    test('returns null when url is not goods-detail page', () {

      const code =

          'url,https://demo.gbuilderchina.com/m/#/pages/order/index?id=64522';



      final id = ProductScanServices.resolveProductIdFromScan(code);



      expect(id, isNull);

    });

  });



  group('ProductScanServices.resolveUniqidsFromScan', () {

    test('parses uniqids from search query params', () {

      const code =

          'https://ceramics.georgebuilder.com/search?uniqids=ECO-FSL-243-01&uniqids=ECO-FSL-197-01';



      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);



      expect(uniqids, ['ECO-FSL-243-01', 'ECO-FSL-197-01']);

    });



    test('parses uniqids with url comma prefix', () {

      const code =

          'url,https://ceramics.georgebuilder.com/search?uniqids=ECO-FSL-243-01&uniqids=ECO-FSL-197-01';



      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);



      expect(uniqids, ['ECO-FSL-243-01', 'ECO-FSL-197-01']);

    });



    test('parses uniqids from hash-route search page', () {

      const code =

          'https://www.georgemetalglass.com/m/#/pages/search/search?uniqids=AAW7029&uniqids=AAW7028';



      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);



      expect(uniqids, ['AAW7029', 'AAW7028']);

    });



    test('returns null when last path segment is not search', () {

      const code = 'https://ceramics.georgebuilder.com/products/list';



      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);



      expect(uniqids, isNull);

    });



    test('returns null when search page has no uniqids query', () {

      const code = 'https://ceramics.georgebuilder.com/search?keyword=foo';



      final uniqids = ProductScanServices.resolveUniqidsFromScan(code);



      expect(uniqids, isNull);

    });

  });



  group('ProductScanServices.resolveQrcodeKeyFromScan', () {

    test('parses qrcode_key from hash-route search page', () {

      const code =

          'https://xxx.com/m/#/pages/search/search?qrcode_key=LsuXEMUzahqh';



      final qrcodeKey = ProductScanServices.resolveQrcodeKeyFromScan(code);



      expect(qrcodeKey, 'LsuXEMUzahqh');

    });



    test('parses qrcode_key from path search query', () {

      const code =

          'https://ceramics.georgebuilder.com/search?qrcode_key=abc123';



      final qrcodeKey = ProductScanServices.resolveQrcodeKeyFromScan(code);



      expect(qrcodeKey, 'abc123');

    });



    test('returns null when search page has no qrcode_key', () {

      const code = 'https://ceramics.georgebuilder.com/search?keyword=foo';



      final qrcodeKey = ProductScanServices.resolveQrcodeKeyFromScan(code);



      expect(qrcodeKey, isNull);

    });

  });



  group('ProductScanServices.resolveFromScan', () {

    test('prefers uniqids over goods-detail id', () {

      const code =

          'https://ceramics.georgebuilder.com/search?uniqids=ECO-FSL-243-01&uniqids=ECO-FSL-197-01';



      final resolved = ProductScanServices.resolveFromScan(code);



      expect(resolved, isA<ProductScanResolveUniqids>());

      final uniqidsResult = resolved! as ProductScanResolveUniqids;

      expect(uniqidsResult.uniqids, ['ECO-FSL-243-01', 'ECO-FSL-197-01']);

      expect(

        uniqidsResult.forwardedHost,

        'ceramics.georgebuilder.com',

      );

    });



    test('falls back to product id for goods-detail url', () {

      const code =

          'https://demo.gbuilderchina.com/pages/goods-detail/goods-detail?id=12345';



      final resolved = ProductScanServices.resolveFromScan(code);



      expect(resolved, isA<ProductScanResolveProductId>());

      final productResult = resolved! as ProductScanResolveProductId;

      expect(productResult.productId, 12345);

      expect(productResult.forwardedHost, 'demo.gbuilderchina.com');

    });



    test('resolves hash-route search uniqids url', () {

      const code =

          'https://www.georgemetalglass.com/m/#/pages/search/search?uniqids=AAW7029&uniqids=AAW7028';



      final resolved = ProductScanServices.resolveFromScan(code);



      expect(resolved, isA<ProductScanResolveUniqids>());

      final uniqidsResult = resolved! as ProductScanResolveUniqids;

      expect(uniqidsResult.uniqids, ['AAW7029', 'AAW7028']);

      expect(uniqidsResult.forwardedHost, 'www.georgemetalglass.com');

    });



    test('resolves hash-route search qrcode_key url', () {

      const code =

          'https://xxx.com/m/#/pages/search/search?qrcode_key=LsuXEMUzahqh';



      final resolved = ProductScanServices.resolveFromScan(code);



      expect(resolved, isA<ProductScanResolveQrcodeKey>());

      final qrcodeResult = resolved! as ProductScanResolveQrcodeKey;

      expect(qrcodeResult.qrcodeKey, 'LsuXEMUzahqh');

      expect(qrcodeResult.forwardedHost, 'xxx.com');

    });



    test('prefers uniqids over qrcode_key', () {

      const code =

          'https://xxx.com/search?uniqids=AAW7029&qrcode_key=LsuXEMUzahqh';



      final resolved = ProductScanServices.resolveFromScan(code);



      expect(resolved, isA<ProductScanResolveUniqids>());

      final uniqidsResult = resolved! as ProductScanResolveUniqids;

      expect(uniqidsResult.uniqids, ['AAW7029']);

    });



    test('returns null for non-url payload', () {

      expect(ProductScanServices.resolveFromScan('not-a-url'), isNull);

    });

  });

}


