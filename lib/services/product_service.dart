import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductLoadException implements Exception {
  const ProductLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductService {
  ProductService({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  static final Uri endpoint = Uri.parse('https://fakestoreapi.com/products');

  final http.Client _client;
  final Duration timeout;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(endpoint).timeout(timeout);

      if (response.statusCode != 200) {
        throw ProductLoadException(_messageForStatus(response.statusCode));
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ProductLoadException {
      rethrow;
    } on TimeoutException {
      throw const ProductLoadException(
        'The server took too long to respond. Check your connection and try again.',
      );
    } on http.ClientException {
      // IOClient rethrows SocketException as a ClientException, so this file
      // needs no dart:io and still builds for the web.
      throw const ProductLoadException(
        'No internet connection. Turn off Airplane mode or check your network.',
      );
    } on FormatException {
      throw const ProductLoadException(
        'The server sent an unreadable response.',
      );
    } on TypeError {
      throw const ProductLoadException(
        'The server sent an unexpected response.',
      );
    } on Exception {
      // TLS failures (captive Wi-Fi, a wrong device clock, a handshake cut off
      // by Airplane mode) are not ClientExceptions but must still reach Retry.
      throw const ProductLoadException(
        'Could not reach the server. Check your connection and try again.',
      );
    }
  }

  String _messageForStatus(int statusCode) {
    if (statusCode == 404) {
      return 'The product catalog was not found (404).';
    }
    if (statusCode >= 500) {
      return 'The server is having problems ($statusCode). Please try again later.';
    }
    return 'The request failed with status $statusCode.';
  }
}
