import 'dart:io';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/screens/cart/quantity_btm_sheet.dart';
import 'package:shoeshop/services/stock_service.dart';
import 'package:shoeshop/widgets/products/heart_btn.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key, required this.cartItem});

  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final quantity = cartItem.quantity;
    Size size = MediaQuery.of(context).size;
    final isAssetImage = cartItem.imageUrl.startsWith("assets/");
    final isNetworkImage =
        cartItem.imageUrl.startsWith("http://") ||
        cartItem.imageUrl.startsWith("https://");
    return FittedBox(
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: isAssetImage
                    ? Image.asset(
                        cartItem.imageUrl,
                        height: size.height * 0.2,
                        width: size.height * 0.2,
                        fit: BoxFit.contain,
                      )
                    : isNetworkImage
                    ? FancyShimmerImage(
                        imageUrl: cartItem.imageUrl,
                        height: size.height * 0.2,
                        width: size.height * 0.2,
                        boxFit: BoxFit.contain,
                      )
                    : Image.file(
                        File(cartItem.imageUrl),
                        height: size.height * 0.2,
                        width: size.height * 0.2,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: 10),
              IntrinsicWidth(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.6,
                          child: TitelesTextWidget(
                            label: cartItem.title,
                            maxLines: 2,
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                cartProvider.removeItem(cartItem.id);
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.darkPrimary,
                              ),
                            ),
                            HeartButtonWidget(
                              productId: cartItem.productId,
                              title: cartItem.title,
                              description: cartItem.description,
                              imageAsset:
                                  cartItem.imageUrl.startsWith("assets/")
                                  ? cartItem.imageUrl
                                  : null,
                              imageUrl: cartItem.imageUrl,
                              price: cartItem.price,
                              sizes: cartItem.sizes ?? [cartItem.size],
                              gender: cartItem.gender,
                              type: cartItem.type,
                              categoryLabel: cartItem.categoryLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SubtitleTextWidget(
                        label: "Broj: ${cartItem.size}",
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SubtitleTextWidget(
                          label: "${cartItem.price.toStringAsFixed(2)} RSD",
                          color: AppColors.darkPrimary,
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final stockQty = await StockService.fetchStockQty(
                              productId: cartItem.productId,
                              size: cartItem.size,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            if (stockQty != null && stockQty <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Nema vise na stanju za ovaj broj.",
                                  ),
                                ),
                              );
                              return;
                            }

                            final result = await showModalBottomSheet<int>(
                              backgroundColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              context: context,
                              builder: (context) {
                                return QuantitySheetBottomWidget(
                                  currentQuantity: quantity,
                                  maxQuantity: stockQty ?? 10,
                                );
                              },
                            );
                            if (result != null && result != quantity) {
                              if (stockQty != null && result > stockQty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Ne moze toliko da se doda."),
                                  ),
                                );
                                return;
                              }
                              cartProvider.updateQuantity(
                                cartItem.id,
                                result,
                                maxQuantity: stockQty,
                              );
                            }
                          },
                          icon: const Icon(IconlyLight.arrowDown2),
                          label: Text("Qty: $quantity"),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ],
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
