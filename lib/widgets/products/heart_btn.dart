import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/providers/wishlist_provider.dart';
import 'package:shoeshop/services/user_prefs.dart';

class HeartButtonWidget extends StatefulWidget {
  const HeartButtonWidget({
    super.key,
    required this.productId,
    this.bkgColor = Colors.transparent,
    this.size = 20,
  });
  final String productId;
  final Color bkgColor;
  final double size;
  @override
  State<HeartButtonWidget> createState() => _HeartButtonWidgetState();
}

class _HeartButtonWidgetState extends State<HeartButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final isInWishlist = wishlistProvider.isInWishlist(widget.productId);
        final iconColor = isDark ? Colors.white : Colors.black;
        return Container(
          decoration:
              BoxDecoration(color: widget.bkgColor, shape: BoxShape.circle),
          child: IconButton(
            style: IconButton.styleFrom(elevation: 10),
            onPressed: () async {
              if (await UserPrefs.isGuest()) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Guest users cannot like, add to cart, or purchase. Please log in.",
                    ),
                  ),
                );
                return;
              }
              wishlistProvider.toggle(widget.productId);
            },
            icon: Icon(
              isInWishlist ? IconlyBold.heart : IconlyLight.heart,
              size: widget.size,
              color: isInWishlist
                  ? iconColor
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }
}
