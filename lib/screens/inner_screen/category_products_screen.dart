import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.title,
    required this.categoryId,
    required this.products,
    this.categoryImage,
  });

  final String title;
  final String categoryId;
  final List<String> products;
  final String? categoryImage;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final Set<String> _selectedColors = {};
  final Set<String> _selectedMaterials = {};
  final TextEditingController _searchController = TextEditingController();
  late List<_CategoryProduct> _allProducts;
  bool _isLoadingProducts = true;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _allProducts = widget.products
        .map(
          (assetPath) => _CategoryProduct(
            id: assetPath,
            title: AppConstants.titleFromId(assetPath),
            description: AppConstants.descriptionFromId(assetPath),
            imageAsset: assetPath,
            color: AppConstants.colorFromId(assetPath),
            material: AppConstants.materialTypeFromId(assetPath),
          ),
        )
        .toList(growable: false);
    _loadFirestoreProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredProducts = _allProducts.where((product) {
      final color = product.color ?? AppConstants.colorFromId(product.id);
      final material =
          product.material ?? AppConstants.materialTypeFromId(product.id);
      final colorOk =
          _selectedColors.isEmpty ||
          (color != null && _selectedColors.contains(color));
      final materialOk =
          _selectedMaterials.isEmpty ||
          (material != null && _selectedMaterials.contains(material));
      if (!(colorOk && materialOk)) {
        return false;
      }
      if (_query.isEmpty) {
        return true;
      }
      final haystack = "${product.title} ${product.description}".toLowerCase();
      final words = _query
          .split(RegExp(r"\s+"))
          .where((word) => word.isNotEmpty)
          .toList(growable: false);
      return words.every(haystack.contains);
    }).toList();

    String emptyMessage() {
      if (_selectedColors.isNotEmpty && _selectedMaterials.isEmpty) {
        return "Nema proizvoda u ovoj boji.";
      }
      if (_selectedMaterials.isNotEmpty && _selectedColors.isEmpty) {
        return "Nema proizvoda u ovom materijalu.";
      }
      if (_selectedColors.isNotEmpty && _selectedMaterials.isNotEmpty) {
        return "Nema proizvoda za izabrane filtere.";
      }
      return "Nema proizvoda u ovoj kategoriji.";
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 96,
        leadingWidth: 56,
        leading: SizedBox(
          width: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              BackButton(color: isDarkMode ? Colors.white : null),
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: isDarkMode ? Colors.white : null,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.categoryImage != null)
              ClipOval(
                child: Image.asset(
                  widget.categoryImage!,
                  height: 28,
                  width: 28,
                  fit: BoxFit.cover,
                ),
              ),
            if (widget.categoryImage != null) const SizedBox(width: 8),
            TitelesTextWidget(
              label: widget.title,
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
                        title: Text(AppConstants.materialFilterLabel(material)),
                        value: _selectedMaterials.contains(material),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedMaterials.add(material);
                            } else {
                              _selectedMaterials.remove(material);
                            }
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pretraga u ovoj kategoriji",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _searchController.clear();
                    setState(() {
                      _query = "";
                    });
                  },
                  child: const Icon(Icons.clear, color: AppColors.darkPrimary),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                  ? Center(
                      child: SubtitleTextWidget(
                        label: _query.isNotEmpty
                            ? "Nema rezultata za pretragu."
                            : emptyMessage(),
                      ),
                    )
                  : GridView.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.5,
                          ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
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
                    ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _loadFirestoreProducts() async {
    try {
      final firestoreFilter = _firestoreFilterForCategory(widget.categoryId);
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('products')
          .where('isActive', isEqualTo: true);

      if (firestoreFilter.gender != null) {
        query = query.where('gender', isEqualTo: firestoreFilter.gender);
      }
      if (firestoreFilter.type != null) {
        query = query.where('type', isEqualTo: firestoreFilter.type);
      }

      final snap = await query.get();
      final dbProducts = <_CategoryProduct>[];
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
          _CategoryProduct(
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
        _isLoadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  _CategoryFirestoreFilter _firestoreFilterForCategory(String categoryId) {
    switch (categoryId) {
      case "women_flats":
        return const _CategoryFirestoreFilter(gender: "women", type: "flat");
      case "women_sneakers":
        return const _CategoryFirestoreFilter(
          gender: "women",
          type: "sneakers",
        );
      case "women_heels":
        return const _CategoryFirestoreFilter(gender: "women", type: "heels");
      case "men_sneakers":
        return const _CategoryFirestoreFilter(gender: "men", type: "sneakers");
      case "men_flat_shoes":
        return const _CategoryFirestoreFilter(gender: "men", type: "flat");
      default:
        return const _CategoryFirestoreFilter();
    }
  }
}

class _CategoryProduct {
  const _CategoryProduct({
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

class _CategoryFirestoreFilter {
  const _CategoryFirestoreFilter({this.gender, this.type});

  final String? gender;
  final String? type;
}
