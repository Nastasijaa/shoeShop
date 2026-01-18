import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/screens/cart/bottom_checkout.dart';
import 'package:shoeshop/screens/cart/cart_widget.dart';
import 'package:shoeshop/screens/root_screen.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/empty_bag.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items.values.toList();
    if (items.isEmpty) {
      return Scaffold(
        body: EmptyBagWidget(
          imagePath: "${AssetsMenager.imagePath}/bag/checkout.png",
          title: "Your Cart is Empty",
          subtitle: "Looks like you haven't added \n anything to your cart yet.",
          buttonText: "Shop Now",
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RootScreen.routeName,
              (route) => false,
            );
          },
        ),
      );
    }
    return Scaffold(
      bottomSheet: const CartBottomSheetWidget(),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(AssetsMenager.logo),
          ),
        ),
        title: const Text("ShoeShop"),
        actions: [
          IconButton(
            onPressed: () {
              cartProvider.clear();
            },
            icon: const Icon(Icons.delete_forever_rounded),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return CartWidget(cartItem: items[index]);
        },
      ),
    );
  }
}
