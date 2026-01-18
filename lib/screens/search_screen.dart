import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;
  late List<_SearchProduct> _allProducts;
  late List<_SearchProduct> _filteredProducts;
  @override //da stalnoučitava
  void initState() {
    searchTextController = TextEditingController();
    _allProducts = List.generate(
      200,
      (index) => _SearchProduct(
        id: "search_$index",
        title: "Title $index",
        description:
            "Description for product $index with extra details for searching",
      ),
    );
    _filteredProducts = _allProducts;
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Image.asset(AssetsMenager.logo),
              ),
          ),
          title: const Text("ShoeShop"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              TextField(
                controller: searchTextController, //dinamika
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      //setState(() {
                      FocusScope.of(context).unfocus();
                      searchTextController.clear();
                      setState(() {
                        _filteredProducts = _allProducts;
                      });
                      //});
                    },
                    child: const Icon(
                      Icons.clear,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                ),
                onChanged: (value) {
                  final query = value.trim().toLowerCase();
                  if (query.isEmpty) {
                    setState(() {
                      _filteredProducts = _allProducts;
                    });
                    return;
                  }
                  final words = query
                      .split(RegExp(r"\s+"))
                      .where((word) => word.isNotEmpty)
                      .toList(growable: false);
                  setState(() {
                    _filteredProducts = _allProducts.where((product) {
                      final haystack =
                          "${product.title} ${product.description}"
                              .toLowerCase();
                      return words.every(haystack.contains);
                    }).toList(growable: false);
                  });
                },
                onSubmitted: (value) {
                  // log("value of the text is $value");
                  // log("value of the controller text: ${searchTextController.text}");
                },
              ),
              const SizedBox(height: 15.0),
              Expanded(
                child: DynamicHeightGridView(
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  builder: (context, index) {
                    return ProductWidget(
                      productId: _filteredProducts[index].id,
                    );
                  },
                  itemCount: _filteredProducts.length,
                  crossAxisCount: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchProduct {
  const _SearchProduct({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}
