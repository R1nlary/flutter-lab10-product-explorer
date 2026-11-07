class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  /// JSON numbers arrive as `int` or `double` depending on the value (the API
  /// sends `64` and `109.95` for prices, `4` and `3.9` for ratings), so every
  /// numeric field is read as `num` first and converted afterwards.
  factory Product.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as Map<String, dynamic>? ?? const {};

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description:
          json['description'] as String? ?? 'No description available.',
      category: json['category'] as String? ?? 'uncategorized',
      imageUrl: json['image'] as String? ?? '',
      rating: (rating['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (rating['count'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  String get heroTag => 'product_image_$id';

  String get deepLink => 'narxoz://store/product/$id';

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
