import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewedProduct {
  const ViewedProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageAsset,
    this.imageUrl,
    this.sizes,
    this.gender,
    this.type,
    this.categoryLabel,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String? imageAsset;
  final String? imageUrl;
  final List<int>? sizes;
  final String? gender;
  final String? type;
  final String? categoryLabel;
}

class ViewedRecentlyProvider with ChangeNotifier {
  ViewedRecentlyProvider() {
    _loadSession(_activeSessionKey);
  }

  static const String _storagePrefix = 'viewed_session_';
  final Map<String, List<ViewedProduct>> _itemsBySession = {};
  final Set<String> _loadedSessions = {};
  String _activeSessionKey = 'guest';

  List<ViewedProduct> get _activeItems =>
      _itemsBySession.putIfAbsent(_activeSessionKey, () => []);

  void setSessionKey(String sessionKey) {
    final normalized = sessionKey.trim().isEmpty ? 'guest' : sessionKey.trim();
    if (_activeSessionKey == normalized) {
      return;
    }
    _activeSessionKey = normalized;
    _loadSession(normalized);
    notifyListeners();
  }

  List<ViewedProduct> get items => List.unmodifiable(_activeItems);

  void addViewed(ViewedProduct product) {
    _activeItems.removeWhere((item) => item.id == product.id);
    _activeItems.insert(0, product);
    _persistSession(_activeSessionKey);
    notifyListeners();
  }

  void clear() {
    _activeItems.clear();
    _persistSession(_activeSessionKey);
    notifyListeners();
  }

  void removeProduct(String productId) {
    final initialLength = _activeItems.length;
    _activeItems.removeWhere((item) => item.id == productId);
    if (initialLength == _activeItems.length) {
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
    final items = <ViewedProduct>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final entry in decoded) {
            if (entry is! Map) {
              continue;
            }
            items.add(_itemFromJson(Map<String, dynamic>.from(entry)));
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
    final items = _itemsBySession[sessionKey] ?? [];
    final payload = items.map(_itemToJson).toList(growable: false);
    await prefs.setString('$_storagePrefix$sessionKey', jsonEncode(payload));
  }

  Map<String, dynamic> _itemToJson(ViewedProduct item) {
    return {
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'imageAsset': item.imageAsset,
      'imageUrl': item.imageUrl,
      'sizes': item.sizes,
      'gender': item.gender,
      'type': item.type,
      'categoryLabel': item.categoryLabel,
    };
  }

  ViewedProduct _itemFromJson(Map<String, dynamic> map) {
    final rawSizes = map['sizes'];
    return ViewedProduct(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageAsset: map['imageAsset']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
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
