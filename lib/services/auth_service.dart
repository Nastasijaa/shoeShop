import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/providers/viewed_recently_provider.dart';
import 'package:shoeshop/providers/wishlist_provider.dart';

class AuthService {
  static const String guestSessionKey = 'guest';

  static String userSessionKey(String email) =>
      'user:${email.trim().toLowerCase()}';

  static void applyGuestSession(
    BuildContext context, {
    bool clearGuestData = false,
  }) {
    final wishlistProvider = context.read<WishlistProvider>();
    final viewedProvider = context.read<ViewedRecentlyProvider>();
    final cartProvider = context.read<CartProvider>();

    wishlistProvider.setSessionKey(guestSessionKey);
    viewedProvider.setSessionKey(guestSessionKey);
    cartProvider.setSessionKey(guestSessionKey);

    if (clearGuestData) {
      wishlistProvider.clear();
      viewedProvider.clear();
      cartProvider.clear();
    }
  }

  static void applyUserSession(BuildContext context, String email) {
    final sessionKey = userSessionKey(email);
    context.read<WishlistProvider>().setSessionKey(sessionKey);
    context.read<ViewedRecentlyProvider>().setSessionKey(sessionKey);
    context.read<CartProvider>().setSessionKey(sessionKey);
  }
}
