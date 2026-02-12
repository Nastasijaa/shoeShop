import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/providers/viewed_recently_provider.dart';
import 'package:shoeshop/providers/wishlist_provider.dart';

class ProductIntegrityService {
  const ProductIntegrityService._();

  static Future<void> syncMissingProducts(BuildContext context) async {
    final wishlistProvider = context.read<WishlistProvider>();
    final viewedProvider = context.read<ViewedRecentlyProvider>();
    final cartProvider = context.read<CartProvider>();

    final ids = <String>{
      ...wishlistProvider.items.map((item) => item.productId),
      ...viewedProvider.items.map((item) => item.id),
      ...cartProvider.items.values.map((item) => item.productId),
    }.where((id) => id.trim().isNotEmpty).toSet();

    if (ids.isEmpty) {
      return;
    }

    final missing = await _findMissingProductIds(ids);
    if (missing.isEmpty) {
      return;
    }

    for (final productId in missing) {
      wishlistProvider.removeProduct(productId);
      viewedProvider.removeProduct(productId);
      cartProvider.removeProduct(productId);
    }
  }

  static void removeDeletedProductFromState(
    BuildContext context,
    String productId,
  ) {
    context.read<WishlistProvider>().removeProduct(productId);
    context.read<ViewedRecentlyProvider>().removeProduct(productId);
    context.read<CartProvider>().removeProduct(productId);
  }

  static Future<Set<String>> _findMissingProductIds(Set<String> ids) async {
    final idList = ids.toList(growable: false);
    final existing = <String>{};

    for (var i = 0; i < idList.length; i += 10) {
      final end = (i + 10 < idList.length) ? i + 10 : idList.length;
      final chunk = idList.sublist(i, end);
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      existing.addAll(snap.docs.map((doc) => doc.id));
    }

    return ids.difference(existing);
  }
}
