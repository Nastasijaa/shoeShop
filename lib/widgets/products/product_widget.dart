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
import 'package:shoeshop/widgets/title_text.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    super.key,
    required this.productId,
    this.imageAsset,
    this.imageUrl,
    this.title,
    this.description,
    this.price,
    this.displayId,
    this.sizes,
  });

  final String productId;
  final String? imageAsset;
  final String? imageUrl;
  final String? title;
  final String? description;
  final double? price;
  final String? displayId;
  final List<int>? sizes;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final displayTitle =
        widget.title ?? AppConstants.titleFromId(widget.productId);
    final displayDescription =
        widget.description ?? AppConstants.descriptionFromId(widget.productId);
    final displayPrice =
        widget.price ?? AppConstants.priceFromId(widget.productId);
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxWidth * 0.78;
          final assetPath = widget.imageAsset ??
              (widget.productId.startsWith("assets/") ? widget.productId : null);
          final networkImage =
              widget.imageUrl != null &&
                      (widget.imageUrl!.startsWith("http://") ||
                          widget.imageUrl!.startsWith("https://"))
                  ? widget.imageUrl!
                  : null;
          final fileImagePath =
              widget.imageUrl != null &&
                      widget.imageUrl!.isNotEmpty &&
                      !widget.imageUrl!.startsWith("http://") &&
                      !widget.imageUrl!.startsWith("https://")
                  ? widget.imageUrl!
                  : null;
          Future<int?> pickSize() async {
            final availableSizes =
                (widget.sizes != null && widget.sizes!.isNotEmpty)
                    ? widget.sizes!
                    : AppConstants.sizesFromId(widget.productId);
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
                return SizeSheetBottomWidget(
                  sizes: availableSizes,
                );
              },
            );
          }
          return GestureDetector(
            onTap: () async {
              Navigator.pushNamed(
                context,
                ProductDetailsScreen.routName,
                arguments: ProductDetailsArgs(
                  id: widget.productId,
                  title: displayTitle,
                  description: displayDescription,
                  price: displayPrice,
                  imageAsset: widget.imageAsset,
                  imageUrl: widget.imageUrl,
                  sizes: widget.sizes,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: assetPath != null
                        ? Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                          )
                        : fileImagePath != null
                            ? Image.file(
                                File(fileImagePath),
                                fit: BoxFit.cover,
                              )
                            : FancyShimmerImage(
                                imageUrl: networkImage ?? AppConstants.imageUrl,
                                boxFit: BoxFit.cover,
                              ),
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
                          label: displayTitle,
                          fontSize: 16,
                          maxLines: 1,
                          color: AppColors.darkPrimary,
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: HeartButtonWidget(productId: widget.productId),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: SubtitleTextWidget(
                    label: displayDescription,
                    fontSize: 11,
                    color: isDarkMode ? Colors.white : Colors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: SubtitleTextWidget(
                          label: "${displayPrice.toStringAsFixed(2)} RSD",
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkPrimary,
                          fontSize: 13,
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
                        if (!context.mounted) {
                          return;
                        }
                        final size = await pickSize();
                        if (!context.mounted || size == null) {
                          return;
                        }
                        final stockQty = await StockService.fetchStockQty(
                          productId: widget.productId,
                          size: size,
                        );
                        if (!context.mounted) {
                          return;
                        }
                        final added = context.read<CartProvider>().addItem(
                              productId: widget.productId,
                              title: displayTitle,
                              price: displayPrice,
                              imageUrl:
                                  widget.imageAsset ??
                                  widget.imageUrl ??
                                  AppConstants.imageUrl,
                              size: size,
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
          );
        },
      ),
    );
  }
}
