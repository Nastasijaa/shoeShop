import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _productIds = {};

  bool isInWishlist(String productId) {
    return _productIds.contains(productId);
  }

  List<String> get items => _productIds.toList(growable: false);

  void toggle(String productId) {
    if (_productIds.contains(productId)) {
      _productIds.remove(productId);
    } else {
      _productIds.add(productId);
    }
    notifyListeners();
  }

  void clear() {
    _productIds.clear();
    notifyListeners();
  }
}
