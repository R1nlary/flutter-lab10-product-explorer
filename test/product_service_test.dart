import 'dart:async';
import 'dart:io';

import 'package:flutter_lab10_product_explorer/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ProductService serviceReturning(String body, int status) {
  return ProductService(
    client: MockClient((_) async => http.Response(body, status)),
  );
}

Matcher failsWith(String text) => throwsA(
  isA<ProductLoadException>().having(
    (e) => e.message,
    'message',
    contains(text),
  ),
);

void main() {
  test('returns products on 200', () async {
    final service = serviceReturning('[{"id": 1, "price": 64}]', 200);

    final products = await service.fetchProducts();

    expect(products.single.price, 64.0);
  });

  test('reports 404 and 500 separately', () {
    expect(serviceReturning('', 404).fetchProducts(), failsWith('404'));
    expect(serviceReturning('', 500).fetchProducts(), failsWith('500'));
  });

  test('reports a broken body', () {
    expect(
      serviceReturning('<html>', 200).fetchProducts(),
      failsWith('unreadable'),
    );
    expect(
      serviceReturning('{"a": 1}', 200).fetchProducts(),
      failsWith('unexpected'),
    );
  });

  test('reports no connection', () {
    final service = ProductService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );

    expect(service.fetchProducts(), failsWith('No internet'));
  });

  test('gives up after the timeout', () {
    final service = ProductService(
      client: MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 10),
    );

    expect(service.fetchProducts(), failsWith('too long'));
  });

  test('reports TLS failures instead of leaking them', () {
    final service = ProductService(
      client: MockClient(
        (_) async => throw const HandshakeException('terminated'),
      ),
    );

    expect(service.fetchProducts(), failsWith('Could not reach'));
  });
}
