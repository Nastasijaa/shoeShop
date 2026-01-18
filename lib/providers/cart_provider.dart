import 'package:flutter/material.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  final String id;
  final String title;
  final double price;
  final String imageUrl;
  int quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  void addItem({
    required String id,
    required String title,
    required double price,
    required String imageUrl,
  }) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(
        id: id,
        title: title,
        price: price,
        imageUrl: imageUrl,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (!_items.containsKey(id)) {
      return;
    }
    if (quantity <= 0) {
      _items.remove(id);
    } else {
      _items[id]!.quantity = quantity;
    }
    notifyListeners();
  }

  void removeItem(String id) {
    if (!_items.containsKey(id)) {
      return;
    }
    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity -= 1;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
