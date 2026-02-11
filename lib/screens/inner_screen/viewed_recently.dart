import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/providers/viewed_recently_provider.dart';
import 'package:shoeshop/screens/root_screen.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/empty_bag.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';
import 'package:shoeshop/widgets/title_text.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = "/ViewedRecentlyScreen";
  const ViewedRecentlyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = context.watch<ViewedRecentlyProvider>().items;
    return items.isEmpty
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
              imagePath: "${AssetsMenager.imagePath}/profile/repeat.png",
              title: "No viewed products yet",
              subtitle: "Browse products to see them here.",
              buttonText: "Browse products",
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  RootScreen.routeName,
                );
              },
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
              title: TitelesTextWidget(
                label: "Viewed recently (${items.length})",
              ),
            ),
            body: DynamicHeightGridView(
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              builder: (context, index) {
                final item = items[index];
                return ProductWidget(
                  productId: item.id,
                  title: item.title,
                  description: item.description,
                  imageAsset: item.imageAsset,
                  imageUrl: item.imageUrl,
                  price: item.price,
                  sizes: item.sizes,
                );
              },
              itemCount: items.length,
              crossAxisCount: 2,
            ),
          );
  }
}
