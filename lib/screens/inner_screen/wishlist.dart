import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/screens/root_screen.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/empty_bag.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';
import 'package:shoeshop/widgets/title_text.dart';
import 'package:shoeshop/providers/wishlist_provider.dart';

class WishlistScreen extends StatelessWidget {
  static const routName = "/WishlistScreen";
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final items = wishlistProvider.items;
        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: const TitelesTextWidget(label: "Wishlist"),
            ),
            body: EmptyBagWidget(
              imagePath: "${AssetsMenager.imagePath}/bag/wishlist.png",
              title: "Nothing in your wishlist yet",
              subtitle: "Looks like your wishlist is empty.",
              buttonText: "Shop now",
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  RootScreen.routeName,
                );
              },
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            title: TitelesTextWidget(label: "Wishlist (${items.length})"),
            actions: [
              IconButton(
                onPressed: () {
                  wishlistProvider.clear();
                },
                icon: const Icon(Icons.delete_forever_rounded),
              ),
            ],
          ),
          body: DynamicHeightGridView(
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            builder: (context, index) {
              return ProductWidget(productId: items[index]);
            },
            itemCount: items.length,
            crossAxisCount: 2,
          ),
        );
      },
    );
  }
}
