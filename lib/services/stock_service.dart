import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shoeshop/consts/stripe_config.dart';
import 'package:shoeshop/providers/cart_provider.dart';

class StockService {
  static Future<int?> fetchStockQty({
    required String productId,
    required int size,
  }) async {
    if (productId.startsWith("assets/")) {
      return null;
    }

    try {
      final stockDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('stocks')
          .doc(size.toString())
          .get();

      if (!stockDoc.exists) {
        return null;
      }

      final data = stockDoc.data() ?? {};
      return (data['qty'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  static Future<void> decreaseStockForOrder(List<CartItem> cartItems) async {
    try {
      await _decreaseStockInFirestore(cartItems);
      return;
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
    }

    await _decreaseStockViaBackend(cartItems);
  }

  static Future<void> _decreaseStockInFirestore(
    List<CartItem> cartItems,
  ) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.runTransaction((transaction) async {
      final stockRefs = <DocumentReference<Map<String, dynamic>>, int>{};
      final labelsByPath = <String, String>{};

      for (final item in cartItems) {
        final productId = item.productId.trim();
        if (productId.isEmpty || productId.startsWith("assets/")) {
          continue;
        }

        final stockRef = firestore
            .collection('products')
            .doc(productId)
            .collection('stocks')
            .doc(item.size.toString());
        stockRefs.update(
          stockRef,
          (value) => value + item.quantity,
          ifAbsent: () => item.quantity,
        );
        labelsByPath.putIfAbsent(
          stockRef.path,
          () => "${item.title} (broj ${item.size})",
        );
      }

      for (final entry in stockRefs.entries) {
        final snapshot = await transaction.get(entry.key);
        final requestedQty = entry.value;
        final label = labelsByPath[entry.key.path] ?? "Proizvod";

        if (!snapshot.exists) {
          throw StateError("$label nije dostupan na stanju.");
        }

        final currentQty = (snapshot.data()?['qty'] as num?)?.toInt() ?? 0;
        if (currentQty < requestedQty) {
          throw StateError(
            "Nema dovoljno na stanju za $label. Dostupno: $currentQty, trazeno: $requestedQty.",
          );
        }

        transaction.update(entry.key, {'qty': currentQty - requestedQty});
      }
    });
  }

  static Future<void> _decreaseStockViaBackend(List<CartItem> cartItems) async {
    final url = StripeConfig.stockUpdateUrl.trim();
    if (url.isEmpty) {
      throw StateError(
        "Nemate dozvolu za smanjenje stock-a iz aplikacije, a STRIPE_STOCK_UPDATE_URL nije podesen.",
      );
    }

    final items = <Map<String, dynamic>>[];
    for (final item in cartItems) {
      final productId = item.productId.trim();
      if (productId.isEmpty || productId.startsWith("assets/")) {
        continue;
      }
      items.add({
        'productId': productId,
        'size': item.size,
        'quantity': item.quantity,
        'title': item.title,
      });
    }

    if (items.isEmpty) {
      return;
    }

    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'items': items}),
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw StateError("Ne mogu da kontaktiram stock backend: $e");
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String backendMessage = '';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final error = decoded['error'];
          if (error is String) {
            backendMessage = error;
          }
        }
      } catch (_) {}
      throw StateError(
        backendMessage.isNotEmpty
            ? "Stock backend greska (${response.statusCode}): $backendMessage"
            : "Stock backend greska (${response.statusCode}).",
      );
    }
  }
}
