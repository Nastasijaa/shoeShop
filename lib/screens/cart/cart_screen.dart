import 'package:flutter/material.dart';
import 'package:shoeshop/screens/cart/bottom_checkout.dart';
import 'package:shoeshop/screens/cart/cart_widget.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/empty_bag.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  final bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: "${AssetsMenager.imagePath}/bag/checkout.png",
              title: "Your Cart is Empty",
              subtitle:
                  "Looks like you haven't added \n anything to your cart yet.",
              buttonText: "Shop Now",
            ),
          )
        : Scaffold(
          bottomSheet: const CartBottomSheetWidget(),
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("${AssetsMenager.imagePath}/logo.png"),
              ),
              title: const Text("ShoeShop"),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_forever_rounded),
                ),
              ],
            ),
            body: ListView.builder(
              //logika cart screena glde da li ima proizvoda ako ima vraca stranicu sa listom proizvoda
              itemCount: 10,
              itemBuilder: (context, index) {
                return const CartWidget();
              },
            ),
          );
  }
}
