import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';
import 'package:shoeshop/widgets/products/product_widget.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.title,
    required this.products,
    this.categoryImage,
  });

  final String title;
  final List<String> products;
  final String? categoryImage;

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final Set<String> _selectedColors = {};
  final Set<String> _selectedMaterials = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredProducts = widget.products.where((assetPath) {
      final color = AppConstants.colorFromId(assetPath);
      final material = AppConstants.materialTypeFromId(assetPath);
      final colorOk = _selectedColors.isEmpty ||
          (color != null && _selectedColors.contains(color));
      final materialOk = _selectedMaterials.isEmpty ||
          (material != null && _selectedMaterials.contains(material));
      if (!(colorOk && materialOk)) {
        return false;
      }
      if (_query.isEmpty) {
        return true;
      }
      final haystack =
          "${AppConstants.titleFromId(assetPath)} ${AppConstants.descriptionFromId(assetPath)}"
              .toLowerCase();
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
              BackButton(
                color: isDarkMode ? Colors.white : null,
              ),
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
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -2),
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
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -2),
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
                  child: const Icon(
                    Icons.clear,
                    color: AppColors.darkPrimary,
                  ),
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
              child: filteredProducts.isEmpty
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
                        final assetPath = filteredProducts[index];
                        return ProductWidget(
                          productId: assetPath,
                          title: AppConstants.titleFromId(assetPath),
                          description: AppConstants.descriptionFromId(assetPath),
                          imageAsset: assetPath,
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
}
