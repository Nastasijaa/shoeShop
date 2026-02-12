import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistItem {
  const WishlistItem({
    required this.productId,
    this.title,
    this.description,
    this.imageAsset,
    this.imageUrl,
    this.price,
    this.sizes,
    this.gender,
    this.type,
    this.categoryLabel,
  });

  final String productId;
  final String? title;
  final String? description;
  final String? imageAsset;
  final String? imageUrl;
  final double? price;
  final List<int>? sizes;
  final String? gender;
  final String? type;
  final String? categoryLabel;
}

class WishlistProvider extends ChangeNotifier {
  WishlistProvider() {
    _loadSession(_activeSessionKey);
  }

  static const String _storagePrefix = 'wishlist_session_';
  final Map<String, Map<String, WishlistItem>> _itemsBySession = {};
  final Set<String> _loadedSessions = {};
  String _activeSessionKey = 'guest';

  Map<String, WishlistItem> get _activeItems =>
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

  bool isInWishlist(String productId) {
    return _activeItems.containsKey(productId);
  }

  List<WishlistItem> get items => _activeItems.values.toList(growable: false);

  void toggle({
    required String productId,
    String? title,
    String? description,
    String? imageAsset,
    String? imageUrl,
    double? price,
    List<int>? sizes,
    String? gender,
    String? type,
    String? categoryLabel,
  }) {
    if (_activeItems.containsKey(productId)) {
      _activeItems.remove(productId);
    } else {
      _activeItems[productId] = WishlistItem(
        productId: productId,
        title: title,
        description: description,
        imageAsset: imageAsset,
        imageUrl: imageUrl,
        price: price,
        sizes: sizes,
        gender: gender,
        type: type,
        categoryLabel: categoryLabel,
      );
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
    final removed = _activeItems.remove(productId);
    if (removed == null) {
      return;
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
    final items = <String, WishlistItem>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final entry in decoded) {
            if (entry is! Map) {
              continue;
            }
            final map = Map<String, dynamic>.from(entry);
            final item = _itemFromJson(map);
            items[item.productId] = item;
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

  Map<String, dynamic> _itemToJson(WishlistItem item) {
    return {
      'productId': item.productId,
      'title': item.title,
      'description': item.description,
      'imageAsset': item.imageAsset,
      'imageUrl': item.imageUrl,
      'price': item.price,
      'sizes': item.sizes,
      'gender': item.gender,
      'type': item.type,
      'categoryLabel': item.categoryLabel,
    };
  }

  WishlistItem _itemFromJson(Map<String, dynamic> map) {
    final rawSizes = map['sizes'];
    return WishlistItem(
      productId: (map['productId'] ?? '').toString(),
      title: map['title']?.toString(),
      description: map['description']?.toString(),
      imageAsset: map['imageAsset']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      price: (map['price'] as num?)?.toDouble(),
      sizes: rawSizes is List
          ? rawSizes
                .map((size) => int.tryParse(size.toString()))
                .whereType<int>()
                .toList(growable: false)
          : null,
      gender: map['gender']?.toString(),
      type: map['type']?.toString(),
      categoryLabel: map['categoryLabel']?.toString(),
    );
  }
}
