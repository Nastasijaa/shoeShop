
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/screens/inner_screen/product_details.dart';
import 'package:shoeshop/services/user_prefs.dart';
import 'package:shoeshop/widgets/products/heart_btn.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';

class LatestArrivalProductsWidget extends StatelessWidget {
  const LatestArrivalProductsWidget({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    const title = "Title";
    const price = 1550.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.pushNamed(context, ProductDetailsScreen.routName);
        },
        child: SizedBox(
          width: size.width * 0.45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: FancyShimmerImage(
                    imageUrl: AppConstants.imageUrl,
                    height: size.width * 0.24,
                    width: size.width * 0.32,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      title * 15,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      child: Row(
                        children: [
                          HeartButtonWidget(productId: productId),
                          IconButton(
                            onPressed: () async {
                              if (await UserPrefs.isGuest()) {
                                if (!context.mounted) {
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
                              if (!context.mounted) {
                                return;
                              }
                              context.read<CartProvider>().addItem(
                                    id: productId,
                                    title: title,
                                    price: price,
                                    imageUrl: AppConstants.imageUrl,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Added to cart"),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const FittedBox(
                      child: SubtitleTextWidget(
                        label: "1550.00 RSD",
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
