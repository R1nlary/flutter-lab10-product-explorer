import 'package:flutter_lab10_product_explorer/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a full product', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Backpack',
      'price': 109.95,
      'description': 'Fits a laptop',
      'category': "men's clothing",
      'image': 'https://example.com/1.png',
      'rating': {'rate': 3.9, 'count': 120},
    });

    expect(product.id, 1);
    expect(product.title, 'Backpack');
    expect(product.price, 109.95);
    expect(product.category, "men's clothing");
    expect(product.imageUrl, 'https://example.com/1.png');
    expect(product.rating, 3.9);
    expect(product.reviewCount, 120);
    expect(product.deepLink, 'narxoz://store/product/1');
  });

  test('accepts whole numbers for double fields', () {
    final product = Product.fromJson({
      'id': 5,
      'price': 695,
      'rating': {'rate': 4, 'count': 400},
    });

    expect(product.price, isA<double>());
    expect(product.price, 695.0);
    expect(product.rating, isA<double>());
    expect(product.rating, 4.0);
  });

  test('falls back on missing and null fields', () {
    final product = Product.fromJson({'title': null, 'rating': null});

    expect(product.id, 0);
    expect(product.title, 'Untitled product');
    expect(product.price, 0.0);
    expect(product.imageUrl, '');
    expect(product.rating, 0.0);
    expect(product.reviewCount, 0);
  });
}
