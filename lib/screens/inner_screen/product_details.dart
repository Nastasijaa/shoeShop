import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/services/user_prefs.dart';
import 'package:shoeshop/widgets/products/heart_btn.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});
  static const routName = "/ProductDetailsScreen";

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigator.canPop(context) ? Navigator.pop(context) : null;
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        // automaticallyImplyLeading: false,
        title: const Text("Shoe Shop"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FancyShimmerImage(
              imageUrl: AppConstants.imageUrl,
              height: size.height * 0.38,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "Title" * 18,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const SubtitleTextWidget(
                        label: "1550.00 RSD",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HeartButtonWidget(
                          productId: "details_0",
                          bkgColor: AppColors.darkPrimary,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            height: kBottomNavigationBarHeight - 10,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
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
                              },
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Add to cart",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitelesTextWidget(label: "About this item"),
                      SubtitleTextWidget(label: "In Books"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SubtitleTextWidget(label: "Description" * 15),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: TitelesTextWidget(label: "Recently viewed"),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: size.height * 0.34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: size.width * 0.6,
                          child: ProductWidget(productId: "recent_$index"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
