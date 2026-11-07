import 'dart:ui';

import 'package:flutter/material.dart';

import 'screens/product_feed_screen.dart';
import 'services/product_service.dart';

void main() {
  runApp(ProductExplorerApp(service: ProductService()));
}

class ProductExplorerApp extends StatelessWidget {
  const ProductExplorerApp({super.key, required this.service});

  final ProductService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Product Explorer',
      debugShowCheckedModeBanner: false,
      // Mouse drag is off by default; the web demo needs it for swipe and refresh.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C1D40)),
      ),
      home: ProductFeedScreen(service: service),
    );
  }
}
