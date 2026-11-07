import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_image.dart';

/// The API returns one photo per product, so the gallery shows that photo
/// three ways: the whole product, then a close-up of the top and of the bottom.
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({super.key, required this.product});

  final Product product;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoView {
  const _PhotoView(this.scale, this.alignment);

  final double scale;
  final Alignment alignment;
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  static const _views = [
    _PhotoView(1, Alignment.center),
    _PhotoView(1.8, Alignment.topCenter),
    _PhotoView(1.8, Alignment.bottomCenter),
  ];

  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: _views.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (_, index) {
                  final view = _views[index];
                  // Only the visible page owns the shared tag, so the Hero
                  // flies back to the feed from whichever photo is on screen.
                  return Hero(
                    tag: index == _currentPage
                        ? 'product_image_${product.id}'
                        : 'product_image_${product.id}_page_$index',
                    // Going back, keep the crop the user is looking at.
                    flightShuttleBuilder: (_, _, direction, from, to) {
                      final source = direction == HeroFlightDirection.pop
                          ? from
                          : to;
                      return (source.widget as Hero).child;
                    },
                    child: ClipRect(
                      child: Transform.scale(
                        scale: view.scale,
                        alignment: view.alignment,
                        child: ProductImage(url: product.imageUrl),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1} / ${_views.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _views.length; i++)
              AnimatedContainer(
                key: ValueKey('carousel_dot_$i'),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPage ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
