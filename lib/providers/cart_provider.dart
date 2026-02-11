import 'dart:math' as math;
import 'package:flutter/material.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.size,
    this.quantity = 1,
  });

  final String id;
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final int size;
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

  int get discountPairs {
    return _calculateDiscountPairs();
  }

  double get discountAmount {
    return _calculateDiscountAmount();
  }

  double get discountedTotalPrice {
    return totalPrice - discountAmount;
  }

  bool addItem({
    required String productId,
    required String title,
    required double price,
    required String imageUrl,
    required int size,
    int? maxQuantity,
  }) {
    final cartId = "$productId-$size";
    if (_items.containsKey(cartId)) {
      final nextQty = _items[cartId]!.quantity + 1;
      if (maxQuantity != null && nextQty > maxQuantity) {
        return false;
      }
      _items[cartId]!.quantity = nextQty;
    } else {
      if (maxQuantity != null && maxQuantity <= 0) {
        return false;
      }
      _items[cartId] = CartItem(
        id: cartId,
        productId: productId,
        title: title,
        price: price,
        imageUrl: imageUrl,
        size: size,
      );
    }
    notifyListeners();
    return true;
  }

  void updateQuantity(String id, int quantity, {int? maxQuantity}) {
    if (!_items.containsKey(id)) {
      return;
    }
    if (maxQuantity != null && quantity > maxQuantity) {
      quantity = maxQuantity;
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

  int _calculateDiscountPairs() {
    final genderedPrices = _collectGenderedPrices();
    return math.min(genderedPrices.male.length, genderedPrices.female.length);
  }

  double _calculateDiscountAmount() {
    final genderedPrices = _collectGenderedPrices();
    final pairs = math.min(genderedPrices.male.length, genderedPrices.female.length);
    if (pairs == 0) {
      return 0.0;
    }
    genderedPrices.male.sort((a, b) => b.compareTo(a));
    genderedPrices.female.sort((a, b) => b.compareTo(a));
    var discount = 0.0;
    for (var i = 0; i < pairs; i++) {
      discount += (genderedPrices.male[i] + genderedPrices.female[i]) * 0.30;
    }
    return discount;
  }

  _GenderedPrices _collectGenderedPrices() {
    final male = <double>[];
    final female = <double>[];
    for (final item in _items.values) {
      final gender = _genderFromId(item.productId);
      if (gender == null) {
        continue;
      }
      final target = gender == _Gender.male ? male : female;
      for (var i = 0; i < item.quantity; i++) {
        target.add(item.price);
      }
    }
    return _GenderedPrices(male: male, female: female);
  }

  _Gender? _genderFromId(String id) {
    final lower = id.toLowerCase();
    if (lower.contains("women")) {
      return _Gender.female;
    }
    if (lower.contains("men")) {
      return _Gender.male;
    }
    return null;
  }
}

class _GenderedPrices {
  const _GenderedPrices({required this.male, required this.female});
  final List<double> male;
  final List<double> female;
}

enum _Gender { male, female }
