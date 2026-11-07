import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/error_view.dart';
import '../widgets/product_tile.dart';
import 'product_detail_screen.dart';

enum FeedStatus { loading, success, error }

class ProductFeedScreen extends StatefulWidget {
  const ProductFeedScreen({super.key, required this.service});

  final ProductService service;

  @override
  State<ProductFeedScreen> createState() => _ProductFeedScreenState();
}

class _ProductFeedScreenState extends State<ProductFeedScreen> {
  FeedStatus _status = FeedStatus.loading;
  List<Product> _products = const [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _retry() {
    setState(() => _status = FeedStatus.loading);
    return _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget.service.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _status = FeedStatus.success;
      });
    } on ProductLoadException catch (error) {
      if (!mounted) return;
      if (_status == FeedStatus.success) {
        // A failed pull-to-refresh keeps the list that is already on screen.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _status = FeedStatus.error;
      });
    }
  }

  void _openDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Product Explorer')),
      body: switch (_status) {
        FeedStatus.loading => const Center(child: CircularProgressIndicator()),
        FeedStatus.error => ErrorView(message: _errorMessage, onRetry: _retry),
        FeedStatus.success => _buildFeed(),
      },
    );
  }

  Widget _buildFeed() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: _products.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 160),
                Center(child: Text('No products yet. Pull down to refresh.')),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _products.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final product = _products[index];
                return ProductTile(
                  product: product,
                  onTap: () => _openDetails(product),
                );
              },
            ),
    );
  }
}
