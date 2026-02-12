import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;
  late List<_SearchProduct> _allProducts;
  late List<_SearchProduct> _filteredProducts;
  late List<String> _searchAssets;
  bool _isLoadingProducts = true;
  final Set<String> _selectedColors = {};
  final Set<String> _selectedMaterials = {};
  final Set<String> _selectedGenders = {};
  final Set<String> _selectedTypes = {};
  String _query = "";
  @override //da stalnoučitava
  void initState() {
    searchTextController = TextEditingController();
    _searchAssets = [
      ...AppConstants.womenFlatAssets,
      ...AppConstants.womenSneakersAssets,
      ...AppConstants.womenHeelsAssets,
      ...AppConstants.menSneakersAssets,
      ...AppConstants.menFlatAssets,
    ];
    _allProducts = List.generate(_searchAssets.length, (index) {
      final assetPath = _searchAssets[index];
      return _SearchProduct(
        id: assetPath,
        title: AppConstants.titleFromId(assetPath),
        description: AppConstants.descriptionFromId(assetPath),
        imageAsset: assetPath,
      );
    });
    _filteredProducts = _allProducts;
    _loadFirestoreProducts();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = _availableTypes();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          title: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  AssetsMenager.logo,
                  height: 28,
                  width: 28,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const TitelesTextWidget(
                label: "ShoeShop",
                color: AppColors.darkPrimary,
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const TitelesTextWidget(
                  label: "Filteri",
                  color: AppColors.darkPrimary,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      const TitelesTextWidget(
                        label: "Pol",
                        color: AppColors.darkPrimary,
                      ),
                      const SizedBox(height: 4),
                      ...AppConstants.filterGenders.map((gender) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -2,
                          ),
                          title: Text(AppConstants.genderLabel(gender)),
                          value: _selectedGenders.contains(gender),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedGenders.add(gender);
                              } else {
                                _selectedGenders.remove(gender);
                              }
                              if (_selectedGenders.length == 1 &&
                                  _selectedGenders.contains("men")) {
                                _selectedTypes.remove("heels");
                              }
                              _applyFilters();
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      const TitelesTextWidget(
                        label: "Kategorije",
                        color: AppColors.darkPrimary,
                      ),
                      const SizedBox(height: 4),
                      ...availableTypes.map((type) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -2,
                          ),
                          title: Text(AppConstants.typeLabel(type)),
                          value: _selectedTypes.contains(type),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedTypes.add(type);
                              } else {
                                _selectedTypes.remove(type);
                              }
                              _applyFilters();
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      const TitelesTextWidget(
                        label: "Boje",
                        color: AppColors.darkPrimary,
                      ),
                      const SizedBox(height: 4),
                      ...AppConstants.filterColors.map((color) {
                        final dotColor = _dotColorForLabel(color);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -2,
                          ),
                          secondary: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                              border: Border.all(
                                color: Colors.black.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          title: Text(AppConstants.colorLabel(color)),
                          value: _selectedColors.contains(color),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedColors.add(color);
                              } else {
                                _selectedColors.remove(color);
                              }
                              _applyFilters();
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      const TitelesTextWidget(
                        label: "Materijal",
                        color: AppColors.darkPrimary,
                      ),
                      const SizedBox(height: 4),
                      ...AppConstants.materialTypes.map((material) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -2,
                          ),
                          title: Text(
                            AppConstants.materialFilterLabel(material),
                          ),
                          value: _selectedMaterials.contains(material),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedMaterials.add(material);
                              } else {
                                _selectedMaterials.remove(material);
                              }
                              _applyFilters();
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedColors.clear();
                              _selectedMaterials.clear();
                              _selectedGenders.clear();
                              _selectedTypes.clear();
                              _applyFilters();
                            });
                          },
                          child: const Text("Ocisti filtere"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                        _query = "";
                        _applyFilters();
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
                  setState(() {
                    _query = value.trim().toLowerCase();
                    _applyFilters();
                  });
                },
                onSubmitted: (value) {
                  // log("value of the text is $value");
                  // log("value of the controller text: ${searchTextController.text}");
                },
              ),
              const SizedBox(height: 15.0),
              Expanded(
                child: _isLoadingProducts
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredProducts.isEmpty
                    ? Center(
                        child: SubtitleTextWidget(
                          label:
                              (_selectedColors.isNotEmpty ||
                                  _selectedMaterials.isNotEmpty ||
                                  _selectedGenders.isNotEmpty ||
                                  _selectedTypes.isNotEmpty)
                              ? "Nema odabranog filtera."
                              : _query.isNotEmpty
                              ? "Nema rezultata za pretragu."
                              : "Nema proizvoda.",
                        ),
                      )
                    : DynamicHeightGridView(
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        builder: (context, index) {
                          final product = _filteredProducts[index];
                          return ProductWidget(
                            productId: product.id,
                            title: product.title,
                            description: product.description,
                            imageAsset: product.imageAsset,
                            imageUrl: product.imageUrl,
                            price: product.price,
                            sizes: product.sizes,
                            gender: product.gender,
                            type: product.type,
                            categoryLabel: product.categoryLabel,
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

  void _applyFilters() {
    final words = _query.isEmpty
        ? const <String>[]
        : _query
              .split(RegExp(r"\s+"))
              .where((word) => word.isNotEmpty)
              .toList(growable: false);
    _filteredProducts = _allProducts
        .where((product) {
          final gender =
              product.gender ?? AppConstants.genderFromId(product.id);
          final type = product.type ?? AppConstants.typeFromId(product.id);
          final color = product.color ?? AppConstants.colorFromId(product.id);
          final material =
              product.material ?? AppConstants.materialTypeFromId(product.id);

          final genderOk =
              _selectedGenders.isEmpty ||
              (gender != null && _selectedGenders.contains(gender));
          final typeOk =
              _selectedTypes.isEmpty ||
              (type != null && _selectedTypes.contains(type));
          final colorOk =
              _selectedColors.isEmpty ||
              (color != null && _selectedColors.contains(color));
          final materialOk =
              _selectedMaterials.isEmpty ||
              (material != null && _selectedMaterials.contains(material));
          if (!(genderOk && typeOk && colorOk && materialOk)) {
            return false;
          }
          if (words.isEmpty) {
            return true;
          }
          final haystack = "${product.title} ${product.description}"
              .toLowerCase();
          return words.every(haystack.contains);
        })
        .toList(growable: false);
  }

  Future<void> _loadFirestoreProducts() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final dbProducts = <_SearchProduct>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final title = (data['title'] as String?)?.trim();
        final description = (data['description'] as String?)?.trim();
        final price = (data['price'] as num?)?.toDouble();
        final imageUrl = (data['imageUrl'] as String?)?.trim();

        final sizesSnap = await doc.reference.collection('stocks').get();
        final sizes = <int>[];
        for (final stock in sizesSnap.docs) {
          final stockData = stock.data();
          final qty = (stockData['qty'] as num?)?.toInt() ?? 0;
          if (qty <= 0) continue;
          final size =
              (stockData['size'] as num?)?.toInt() ?? int.tryParse(stock.id);
          if (size != null) sizes.add(size);
        }

        dbProducts.add(
          _SearchProduct(
            id: doc.id,
            title: title?.isNotEmpty == true ? title! : "Proizvod",
            description: description ?? "",
            imageAsset: null,
            imageUrl: imageUrl,
            price: price,
            sizes: sizes,
            gender: data['gender'] as String?,
            type: data['type'] as String?,
            categoryLabel: AppConstants.categoryLabelFromMeta(
              gender: data['gender'] as String?,
              type: data['type'] as String?,
              id: doc.id,
            ),
            color: data['color'] as String?,
            material: data['material'] as String?,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _allProducts = [..._allProducts, ...dbProducts];
        _applyFilters();
        _isLoadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  List<String> _availableTypes() {
    if (_selectedGenders.length == 1 && _selectedGenders.contains("men")) {
      return const ["flat", "sneakers"];
    }
    return AppConstants.filterTypes;
  }

  Color _dotColorForLabel(String color) {
    switch (color) {
      case "bele":
        return Colors.white;
      case "crne":
        return Colors.black;
      case "braon":
        return const Color(0xff8b5a2b);
      case "plave":
        return Colors.blue;
      case "roze":
        return Colors.pink;
      case "zute":
        return Colors.yellow;
      case "bez":
        return const Color(0xfff5deb3);
      case "sive":
        return Colors.grey;
      case "bordo":
        return const Color(0xff6d1b1b);
      default:
        return Colors.transparent;
    }
  }
}

class _SearchProduct {
  const _SearchProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.imageUrl,
    this.price,
    this.sizes,
    this.gender,
    this.type,
    this.categoryLabel,
    this.color,
    this.material,
  });

  final String id;
  final String title;
  final String description;
  final String? imageAsset;
  final String? imageUrl;
  final double? price;
  final List<int>? sizes;
  final String? gender;
  final String? type;
  final String? categoryLabel;
  final String? color;
  final String? material;
}
