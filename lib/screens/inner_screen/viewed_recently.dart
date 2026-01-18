import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/empty_bag.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';
import 'package:shoeshop/widgets/title_text.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = "/ViewedRecentlyScreen";
  const ViewedRecentlyScreen({super.key});
  final bool isEmpty = false;
  @override
  Widget build(BuildContext context) {
    return isEmpty
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: const TitelesTextWidget(label: "Viewed recently"),
            ),
            body: EmptyBagWidget(
              imagePath: "${AssetsMenager.imagePath}/bag/checkout.png",
              title: "No viewed products yet",
              subtitle: "Looks like your cart is empty.",
              buttonText: "Shop now",
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: const TitelesTextWidget(label: "Viewed recently (6)"),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_forever_rounded),
                ),
              ],
            ),
            body: DynamicHeightGridView(
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              builder: (context, index) {
                return ProductWidget(productId: "recent_$index");
              },
              itemCount: 200,
              crossAxisCount: 2,
            ),
          );
  }
}
