import 'package:cloud_firestore/cloud_firestore.dart';

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
}
