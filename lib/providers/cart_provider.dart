import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    this.description,
    required this.price,
    required this.imageUrl,
    required this.size,
    this.sizes,
    this.gender,
    this.type,
    this.categoryLabel,
    this.quantity = 1,
  });

  final String id;
  final String productId;
  final String title;
  final String? description;
  final double price;
  final String imageUrl;
  final int size;
  final List<int>? sizes;
  final String? gender;
  final String? type;
  final String? categoryLabel;
  int quantity;
}

class CartProvider with ChangeNotifier {
  CartProvider() {
    _loadSession(_activeSessionKey);
  }

  static const String _storagePrefix = 'cart_session_';
  final Map<String, Map<String, CartItem>> _itemsBySession = {};
  final Set<String> _loadedSessions = {};
  String _activeSessionKey = 'guest';

  Map<String, CartItem> get _activeItems =>
      _itemsBySession.putIfAbsent(_activeSessionKey, () => {});

  void setSessionKey(String sessionKey) {
    final normalized = sessionKey.trim().isEmpty ? 'guest' : sessionKey.trim();
    if (_activeSessionKey == normalized) {
      return;
    }
    _activeSessionKey = normalized;
    _loadSession(normalized);
    notifyListeners();
  }

  Map<String, CartItem> get items => {..._activeItems};

  int get itemCount => _activeItems.length;

  int get totalQuantity {
    return _activeItems.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _activeItems.values.fold(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
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
    String? description,
    required double price,
    required String imageUrl,
    required int size,
    List<int>? sizes,
    String? gender,
    String? type,
    String? categoryLabel,
    int? maxQuantity,
  }) {
    final cartId = "$productId-$size";
    if (_activeItems.containsKey(cartId)) {
      final nextQty = _activeItems[cartId]!.quantity + 1;
      if (maxQuantity != null && nextQty > maxQuantity) {
        return false;
      }
      _activeItems[cartId]!.quantity = nextQty;
    } else {
      if (maxQuantity != null && maxQuantity <= 0) {
        return false;
      }
      _activeItems[cartId] = CartItem(
        id: cartId,
        productId: productId,
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
        size: size,
        sizes: sizes,
        gender: gender,
        type: type,
        categoryLabel: categoryLabel,
      );
    }
    _persistSession(_activeSessionKey);
    notifyListeners();
    return true;
  }

  void updateQuantity(String id, int quantity, {int? maxQuantity}) {
    if (!_activeItems.containsKey(id)) {
      return;
    }
    if (maxQuantity != null && quantity > maxQuantity) {
      quantity = maxQuantity;
    }
    if (quantity <= 0) {
      _activeItems.remove(id);
    } else {
      _activeItems[id]!.quantity = quantity;
    }
    _persistSession(_activeSessionKey);
    notifyListeners();
  }

  void removeItem(String id) {
    if (!_activeItems.containsKey(id)) {
      return;
    }
    if (_activeItems[id]!.quantity > 1) {
      _activeItems[id]!.quantity -= 1;
    } else {
      _activeItems.remove(id);
    }
    _persistSession(_activeSessionKey);
    notifyListeners();
  }

  void clear() {
    _activeItems.clear();
    _persistSession(_activeSessionKey);
    notifyListeners();
  }

  void removeProduct(String productId) {
    final keysToDelete = _activeItems.entries
        .where((entry) => entry.value.productId == productId)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (keysToDelete.isEmpty) {
      return;
    }
    for (final key in keysToDelete) {
      _activeItems.remove(key);
    }
    _persistSession(_activeSessionKey);
    notifyListeners();
  }

  Future<void> _loadSession(String sessionKey) async {
    if (_loadedSessions.contains(sessionKey)) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_storagePrefix$sessionKey');
    final items = <String, CartItem>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final entry in decoded) {
            if (entry is! Map) {
              continue;
            }
            final item = _itemFromJson(Map<String, dynamic>.from(entry));
            items[item.id] = item;
          }
        }
      } catch (_) {}
    }
    _itemsBySession[sessionKey] = items;
    _loadedSessions.add(sessionKey);
    if (_activeSessionKey == sessionKey) {
      notifyListeners();
    }
  }

  Future<void> _persistSession(String sessionKey) async {
    if (!_loadedSessions.contains(sessionKey)) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final items = _itemsBySession[sessionKey] ?? {};
    final payload = items.values.map(_itemToJson).toList(growable: false);
    await prefs.setString('$_storagePrefix$sessionKey', jsonEncode(payload));
  }

  Map<String, dynamic> _itemToJson(CartItem item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'imageUrl': item.imageUrl,
      'size': item.size,
      'sizes': item.sizes,
      'gender': item.gender,
      'type': item.type,
      'categoryLabel': item.categoryLabel,
      'quantity': item.quantity,
    };
  }

  CartItem _itemFromJson(Map<String, dynamic> map) {
    final rawSizes = map['sizes'];
    return CartItem(
      id: (map['id'] ?? '').toString(),
      productId: (map['productId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: map['description']?.toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (map['imageUrl'] ?? '').toString(),
      size: int.tryParse((map['size'] ?? '').toString()) ?? 0,
      sizes: rawSizes is List
          ? rawSizes
                .map((value) => int.tryParse(value.toString()))
                .whereType<int>()
                .toList(growable: false)
          : null,
      gender: map['gender']?.toString(),
      type: map['type']?.toString(),
      categoryLabel: map['categoryLabel']?.toString(),
      quantity: int.tryParse((map['quantity'] ?? '').toString()) ?? 1,
    );
  }

  int _calculateDiscountPairs() {
    final genderedPrices = _collectGenderedPrices();
    return math.min(genderedPrices.male.length, genderedPrices.female.length);
  }

  double _calculateDiscountAmount() {
    final genderedPrices = _collectGenderedPrices();
    final pairs = math.min(
      genderedPrices.male.length,
      genderedPrices.female.length,
    );
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
    for (final item in _activeItems.values) {
      final gender = _genderFromItem(item);
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

  _Gender? _genderFromItem(CartItem item) {
    final explicit = item.gender?.trim().toLowerCase();
    if (explicit == "women") {
      return _Gender.female;
    }
    if (explicit == "men") {
      return _Gender.male;
    }
    return _genderFromId(item.productId);
  }
}

class _GenderedPrices {
  const _GenderedPrices({required this.male, required this.female});
  final List<double> male;
  final List<double> female;
}

enum _Gender { male, female }
