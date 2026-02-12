import 'dart:io';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/providers/viewed_recently_provider.dart';
import 'package:shoeshop/screens/cart/size_btm_sheet.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/services/stock_service.dart';
import 'package:shoeshop/services/user_prefs.dart';
import 'package:shoeshop/widgets/products/heart_btn.dart';
import 'package:shoeshop/widgets/products/latest_arrival.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});
  static const routName = "/ProductDetailsScreen";

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int? _selectedSize;
  String? _lastViewedId;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ProductDetailsArgs?;
    final productId = args?.id ?? "details_0";
    final title = args?.title ?? AppConstants.titleFromId(productId);
    final description =
        args?.description ?? AppConstants.descriptionFromId(productId);
    final price = args?.price ?? AppConstants.priceFromId(productId);
    final imageAsset = args?.imageAsset;
    final imageUrl = args?.imageUrl;
    final isNetworkImage =
        imageUrl != null &&
        (imageUrl.startsWith("http://") || imageUrl.startsWith("https://"));
    final isLocalImage =
        imageUrl != null && imageUrl.isNotEmpty && !isNetworkImage;
    final sizes = args?.sizes;
    final categoryLabel =
        args?.categoryLabel ??
        AppConstants.categoryLabelFromMeta(
          gender: args?.gender,
          type: args?.type,
          id: productId,
        );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.darkPrimary;
    final bodyTextColor = isDark ? Colors.white : Colors.black;
    Size size = MediaQuery.of(context).size;

    if (_lastViewedId != productId) {
      _lastViewedId = productId;
      context.read<ViewedRecentlyProvider>().addViewed(
        ViewedProduct(
          id: productId,
          title: title,
          description: description,
          price: price,
          imageAsset: imageAsset,
          imageUrl: imageUrl,
          sizes: sizes,
          gender: args?.gender,
          type: args?.type,
          categoryLabel: categoryLabel,
        ),
      );
    }

    final viewedItems = context.watch<ViewedRecentlyProvider>().items;
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
        title: const TitelesTextWidget(
          label: "ShoeShop",
          color: AppColors.darkPrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            imageAsset != null
                ? Image.asset(
                    imageAsset,
                    height: size.height * 0.38,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : isLocalImage
                ? Image.file(
                    File(imageUrl),
                    height: size.height * 0.38,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : FancyShimmerImage(
                    imageUrl: imageUrl ?? AppConstants.imageUrl,
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
                          title,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SubtitleTextWidget(
                        label: "${price.toStringAsFixed(2)} RSD",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _showMeasure(context),
                        child: const Text("View measure"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffcfead7),
                          foregroundColor: AppColors.darkPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 18,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () => _pickSize(context, productId),
                        child: Text(
                          _selectedSize == null
                              ? "Choose number"
                              : "Choose number (${_selectedSize!})",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeartButtonWidget(
                          productId: productId,
                          bkgColor: AppColors.darkPrimary,
                          title: title,
                          description: description,
                          imageAsset: imageAsset,
                          imageUrl: imageUrl,
                          price: price,
                          sizes: sizes,
                          gender: args?.gender,
                          type: args?.type,
                          categoryLabel: categoryLabel,
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
                                if (!context.mounted) {
                                  return;
                                }
                                if (_selectedSize == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Choose number"),
                                    ),
                                  );
                                  return;
                                }
                                final stockQty =
                                    await StockService.fetchStockQty(
                                      productId: productId,
                                      size: _selectedSize!,
                                    );
                                if (!context.mounted) {
                                  return;
                                }
                                final added = context
                                    .read<CartProvider>()
                                    .addItem(
                                      productId: productId,
                                      title: title,
                                      description: description,
                                      price: price,
                                      imageUrl:
                                          imageAsset ??
                                          imageUrl ??
                                          AppConstants.imageUrl,
                                      size: _selectedSize!,
                                      sizes: sizes,
                                      gender: args?.gender,
                                      type: args?.type,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitelesTextWidget(
                        label: "About this item",
                        color: titleColor,
                      ),
                      SubtitleTextWidget(
                        label: categoryLabel,
                        color: bodyTextColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SubtitleTextWidget(label: description, color: bodyTextColor),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: TitelesTextWidget(
                      label: "Latest arrival",
                      color: AppColors.darkPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: size.height * 0.34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.latestArrivalBrownAssets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final assetPath =
                            AppConstants.latestArrivalBrownAssets[index];
                        return SizedBox(
                          width: size.width * 0.6,
                          child: LatestArrivalProductsWidget(
                            productId: assetPath,
                            title: AppConstants.titleFromId(assetPath),
                            description: AppConstants.descriptionFromId(
                              assetPath,
                            ),
                            imageAsset: assetPath,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TitelesTextWidget(
                      label: "Viewed recently",
                      color: AppColors.darkPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (viewedItems.isEmpty)
                    const SubtitleTextWidget(
                      label: "Nema pregledanih proizvoda.",
                    )
                  else
                    SizedBox(
                      height: size.height * 0.34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewedItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = viewedItems[index];
                          return SizedBox(
                            width: size.width * 0.6,
                            child: LatestArrivalProductsWidget(
                              productId: item.id,
                              title: item.title,
                              description: item.description,
                              imageAsset: item.imageAsset,
                              imageUrl: item.imageUrl,
                              price: item.price,
                              sizes: item.sizes,
                              gender: item.gender,
                              type: item.type,
                              categoryLabel: item.categoryLabel,
                            ),
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

  Future<void> _pickSize(BuildContext context, String productId) async {
    final args =
        ModalRoute.of(context)?.settings.arguments as ProductDetailsArgs?;
    final availableSizes = (args?.sizes != null && args!.sizes!.isNotEmpty)
        ? args.sizes!
        : AppConstants.sizesFromId(productId);
    final size = await showModalBottomSheet<int>(
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
          currentSize: _selectedSize,
        );
      },
    );
    if (size != null && mounted) {
      setState(() {
        _selectedSize = size;
      });
    }
  }

  void _showMeasure(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.asset("${AssetsMenager.imagePath}/measure.jpg"),
        );
      },
    );
  }
}

class ProductDetailsArgs {
  const ProductDetailsArgs({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageAsset,
    this.imageUrl,
    this.sizes,
    this.gender,
    this.type,
    this.categoryLabel,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String? imageAsset;
  final String? imageUrl;
  final List<int>? sizes;
  final String? gender;
  final String? type;
  final String? categoryLabel;
}
