import 'package:flutter/material.dart';

class ViewedProduct {
  const ViewedProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageAsset,
    this.imageUrl,
    this.sizes,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String? imageAsset;
  final String? imageUrl;
  final List<int>? sizes;
}

class ViewedRecentlyProvider with ChangeNotifier {
  final List<ViewedProduct> _items = [];

  List<ViewedProduct> get items => List.unmodifiable(_items);

  void addViewed(ViewedProduct product) {
    _items.removeWhere((item) => item.id == product.id);
    _items.insert(0, product);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
