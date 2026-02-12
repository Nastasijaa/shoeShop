import 'dart:io';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/screens/inner_screen/product_details.dart';
import 'package:shoeshop/screens/cart/size_btm_sheet.dart';
import 'package:shoeshop/services/stock_service.dart';
import 'package:shoeshop/services/user_prefs.dart';
import 'package:shoeshop/widgets/products/heart_btn.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';

class LatestArrivalProductsWidget extends StatelessWidget {
  const LatestArrivalProductsWidget({
    super.key,
    required this.productId,
    this.imageAsset,
    this.imageUrl,
    this.title,
    this.description,
    this.price,
    this.sizes,
    this.gender,
    this.type,
    this.categoryLabel,
  });

  final String productId;
  final String? imageAsset;
  final String? imageUrl;
  final String? title;
  final String? description;
  final double? price;
  final List<int>? sizes;
  final String? gender;
  final String? type;
  final String? categoryLabel;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final displayTitle = title ?? AppConstants.titleFromId(productId);
    final displayDescription =
        description ?? AppConstants.descriptionFromId(productId);
    final displayPrice = price ?? AppConstants.priceFromId(productId);
    final isNetworkImage =
        imageUrl != null &&
        (imageUrl!.startsWith("http://") || imageUrl!.startsWith("https://"));
    final isLocalImage =
        imageUrl != null && imageUrl!.isNotEmpty && !isNetworkImage;
    Future<int?> pickSize() async {
      final availableSizes = (sizes != null && sizes!.isNotEmpty)
          ? sizes!
          : AppConstants.sizesFromId(productId);
      return showModalBottomSheet<int>(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        context: context,
        builder: (context) {
          return SizeSheetBottomWidget(sizes: availableSizes);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.pushNamed(
            context,
            ProductDetailsScreen.routName,
            arguments: ProductDetailsArgs(
              id: productId,
              title: displayTitle,
              description: displayDescription,
              price: displayPrice,
              imageAsset: imageAsset,
              imageUrl: imageUrl,
              sizes: sizes,
              gender: gender,
              type: type,
              categoryLabel: categoryLabel,
            ),
          );
        },
        child: SizedBox(
          width: size.width * 0.45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: imageAsset != null
                      ? Image.asset(
                          imageAsset!,
                          height: size.width * 0.24,
                          width: size.width * 0.32,
                          fit: BoxFit.cover,
                        )
                      : isLocalImage
                      ? Image.file(
                          File(imageUrl!),
                          height: size.width * 0.24,
                          width: size.width * 0.32,
                          fit: BoxFit.cover,
                        )
                      : FancyShimmerImage(
                          imageUrl: imageUrl ?? AppConstants.imageUrl,
                          height: size.width * 0.24,
                          width: size.width * 0.32,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    SubtitleTextWidget(
                      label: displayDescription,
                      fontSize: 11,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      child: Row(
                        children: [
                          HeartButtonWidget(
                            productId: productId,
                            title: displayTitle,
                            description: displayDescription,
                            imageAsset: imageAsset,
                            imageUrl: imageUrl,
                            price: displayPrice,
                            sizes: sizes,
                            gender: gender,
                            type: type,
                            categoryLabel: categoryLabel,
                          ),
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
                              final size = await pickSize();
                              if (!context.mounted || size == null) {
                                return;
                              }
                              final stockQty = await StockService.fetchStockQty(
                                productId: productId,
                                size: size,
                              );
                              if (!context.mounted) {
                                return;
                              }
                              final added = context
                                  .read<CartProvider>()
                                  .addItem(
                                    productId: productId,
                                    title: displayTitle,
                                    description: displayDescription,
                                    price: displayPrice,
                                    imageUrl:
                                        imageAsset ??
                                        imageUrl ??
                                        AppConstants.imageUrl,
                                    size: size,
                                    sizes: sizes,
                                    gender: gender,
                                    type: type,
                                    categoryLabel: categoryLabel,
                                    maxQuantity: stockQty,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    added
                                        ? "Added to cart"
                                        : "Ne moze toliko da se doda za izabrani broj.",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      child: SubtitleTextWidget(
                        label: "${displayPrice.toStringAsFixed(2)} RSD",
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
