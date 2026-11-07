import 'package:flutter/material.dart';

class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1)),
        const SizedBox(width: 6),
        Text(
          '($reviewCount reviews)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
