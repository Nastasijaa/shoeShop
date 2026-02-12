import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutAddress {
  const CheckoutAddress({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String city;

  bool get isEmpty =>
      firstName.trim().isEmpty &&
      lastName.trim().isEmpty &&
      phone.trim().isEmpty &&
      email.trim().isEmpty &&
      address.trim().isEmpty &&
      city.trim().isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'city': city.trim(),
    };
  }

  static CheckoutAddress fromMap(Map<String, dynamic> map) {
    return CheckoutAddress(
      firstName: (map['firstName'] ?? '').toString(),
      lastName: (map['lastName'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
    );
  }
}

class AddressService {
  const AddressService._();

  static String _prefsKey(String userId) => 'default_address_$userId';

  static DocumentReference<Map<String, dynamic>> _addressDocRef(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('default_address');
  }

  static Future<CheckoutAddress?> loadDefaultAddress(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) {
      return null;
    }

    final local = await _loadFromPrefs(id);
    try {
      final remoteDoc = await _addressDocRef(id).get();
      if (remoteDoc.exists) {
        final data = remoteDoc.data() ?? {};
        final remoteAddress = CheckoutAddress.fromMap(data);
        if (!remoteAddress.isEmpty) {
          await _saveToPrefs(id, remoteAddress);
          return remoteAddress;
        }
      }

      final fromLastOrder = await _loadFromLatestOrder(id);
      if (fromLastOrder != null && !fromLastOrder.isEmpty) {
        await saveDefaultAddress(id, fromLastOrder);
        return fromLastOrder;
      }
    } catch (_) {
      // Fall back to locally cached address when Firestore is not accessible.
    }

    return local;
  }

  static Future<void> saveDefaultAddress(
    String userId,
    CheckoutAddress address,
  ) async {
    final id = userId.trim();
    if (id.isEmpty || address.isEmpty) {
      return;
    }

    await _saveToPrefs(id, address);

    try {
      await _addressDocRef(id).set({
        ...address.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Local cache was already saved; remote sync can be retried later.
    }
  }

  static Future<CheckoutAddress?> _loadFromLatestOrder(String userId) async {
    final ordersSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (ordersSnap.docs.isEmpty) {
      return null;
    }

    final data = ordersSnap.docs.first.data();
    final fromOrder = CheckoutAddress(
      firstName: (data['customerFirstName'] ?? '').toString(),
      lastName: (data['customerLastName'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
    );
    return fromOrder.isEmpty ? null : fromOrder;
  }

  static Future<CheckoutAddress?> _loadFromPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey(userId));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final address = CheckoutAddress.fromMap(decoded);
      return address.isEmpty ? null : address;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveToPrefs(
    String userId,
    CheckoutAddress address,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey(userId), jsonEncode(address.toMap()));
  }
}
