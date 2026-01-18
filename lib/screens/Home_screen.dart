import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/modals/categories_model.dart';
import 'package:shoeshop/providers/theme_provider.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/ctg_rounded_widget.dart';
import 'package:shoeshop/widgets/map_section.dart';
import 'package:shoeshop/widgets/products/latest_arrival.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';
//import 'package:card_swiper/card_swiper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    void showCategoryPicker({
      required String title,
      required List<CategoriesModel> categories,
    }) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitelesTextWidget(label: title),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: List.generate(categories.length, (index) {
                    final category = categories[index];
                    return CategoryRoundedWidget(
                      name: category.name,
                      image: category.image,
                      icon: category.icon,
                      onTap: () {
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(AssetsMenager.logo),
          ),
        ),
        title: const Text("Shoe Shop"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12.0),
              const TitelesTextWidget(label: "Categories"),
              const SizedBox(height: 12.0),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                children: List.generate(AppConstants.categoriesList.length, (
                  index,
                ) {
                  final category = AppConstants.categoriesList[index];
                  final categories = category.name == "Men"
                      ? AppConstants.menCategoriesList
                      : AppConstants.womenCategoriesList;
                  return CategoryRoundedWidget(
                    image: category.image,
                    icon: category.icon,
                    name: category.name,
                    onTap: () {
                      showCategoryPicker(
                        title: category.name,
                        categories: categories,
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              const TitelesTextWidget(label: "Promo"),
              const SizedBox(height: 12.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: AppColors.lightCardColor,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Image.asset(
                          "${AssetsMenager.imagePath}/sale.jpg",
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                          child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "BUY ONE MEN'S AND ONE WOMEN'S PAIR OF SHOES AND GET 30% OFF",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: AppColors.darkPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const TitelesTextWidget(label: "Latest arrival"),
              const SizedBox(height: 12.0),
              SizedBox(
                height: size.height * 0.18,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return LatestArrivalProductsWidget(
                      productId: "latest_$index",
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              const TitelesTextWidget(label: "Store locations"),
              const SizedBox(height: 12.0),
              SizedBox(
                height: size.height * 0.22,
                child: Swiper(
                  autoplay: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            AppConstants.bannersImages[index],
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.35),
                          ),
                          const Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitelesTextWidget(
                                  label: "Shoe Shop - Novi Sad",
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                SubtitleTextWidget(
                                  label: "Bulevar Oslobodjenja 88",
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: AppConstants.bannersImages.length,
                  pagination: const SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                      activeColor: AppColors.darkPrimary,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: size.height * 0.28,
                  child: const MapSection(),
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.darkPrimary.withOpacity(0.25),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Vasa najudobnija obuca za svaki korak",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    SubtitleTextWidget(
                      label: "Stil, kvalitet i udobnost u srcu Novog Sada.",
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const TitelesTextWidget(label: "Contact"),
              const SizedBox(height: 8.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone),
                          const SizedBox(width: 8),
                          const SubtitleTextWidget(label: "+381 21 555 012"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.mail_outline),
                          const SizedBox(width: 8),
                          const SubtitleTextWidget(label: "hello@shoeshop.rs"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.facebook),
                          const SizedBox(width: 8),
                          const SubtitleTextWidget(label: "/shoeshopns"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.camera_alt),
                          const SizedBox(width: 8),
                          const SubtitleTextWidget(label: "@shoeshopns"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
