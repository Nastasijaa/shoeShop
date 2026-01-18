import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/screens/inner_screen/product_details.dart';
import 'package:shoeshop/services/user_prefs.dart';
import 'package:shoeshop/widgets/products/heart_btn.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({super.key, required this.productId});

  final String productId;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.pushNamed(context, ProductDetailsScreen.routName);
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: FancyShimmerImage(
                imageUrl: AppConstants.imageUrl,
                height: size.height * 0.22,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: TitelesTextWidget(
                      label: "Title " * 10,
                      fontSize: 18,
                      maxLines: 2,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: HeartButtonWidget(productId: widget.productId),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SubtitleTextWidget(
                  label: "ID: ${widget.productId}",
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    flex: 1,
                    child: SubtitleTextWidget(
                      label: "1200 RSD",
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                  Flexible(
                    child: Material(
                      borderRadius: BorderRadius.circular(12.0),
                      color: AppColors.lightPrimary,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () async {
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
                      },
                      splashColor: Colors.blueGrey,
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.add_shopping_cart_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
