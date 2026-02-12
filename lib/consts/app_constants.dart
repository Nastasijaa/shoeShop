import 'package:flutter/material.dart';
import 'package:shoeshop/modals/categories_model.dart';
import 'package:shoeshop/services/assets_menager.dart';

class AppConstants {
  static const String imageUrl = 'https://www.adidas.com/us/shoes';

  static List<String> bannersImages = [
    "${AssetsMenager.imagePath}/banners/shop.jpg",
    "${AssetsMenager.imagePath}/banners/shop2.jpg",
  ];

  static List<CategoriesModel> categoriesList = [
    CategoriesModel(id: "men", name: "Men", icon: Icons.male),
    CategoriesModel(id: "women", name: "Women", icon: Icons.female),
  ];

  static List<CategoriesModel> menCategoriesList = [
    CategoriesModel(
      id: "men_sneakers",
      name: "Sneakers",
      image: "${AssetsMenager.imagePath}/categories/sneakers.png",
    ),
    CategoriesModel(
      id: "men_flat_shoes",
      name: "Flat Shoes",
      image: "${AssetsMenager.imagePath}/categories/mensflat.png",
    ),
  ];

  static List<CategoriesModel> womenCategoriesList = [
    CategoriesModel(
      id: "women_flats",
      name: "Flats",
      image: "${AssetsMenager.imagePath}/categories/flat.png",
    ),
    CategoriesModel(
      id: "women_sneakers",
      name: "Sneakers",
      image: "${AssetsMenager.imagePath}/categories/sneakers.png",
    ),
    CategoriesModel(
      id: "women_heels",
      name: "Heels",
      image: "${AssetsMenager.imagePath}/categories/heels.png",
    ),
  ];

  static List<String> womenFlatAssets = [
    "${AssetsMenager.imagePath}/categories/Women_flat/bele-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Women_flat/bez-skaj (2).jpg",
    "${AssetsMenager.imagePath}/categories/Women_flat/bez-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Women_flat/bordo-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Women_flat/braon-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Women_flat/crne-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Women_flat/roze-tekstil.jpg",
  ];

  static List<String> womenSneakersAssets = [
    "${AssetsMenager.imagePath}/categories/Women_sneakers/bele-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Women_sneakers/bez-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Women_sneakers/bordo-tekstil.jpg",
    "${AssetsMenager.imagePath}/categories/Women_sneakers/braon-tektil.webp",
    "${AssetsMenager.imagePath}/categories/Women_sneakers/crne-tekstil.jpg",
    "${AssetsMenager.imagePath}/categories/Women_sneakers/roze-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Women_sneakers/zute-tekstil.webp",
  ];

  static List<String> womenHeelsAssets = [
    "${AssetsMenager.imagePath}/categories/Women_heels/bele-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Women_heels/bez-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Women_heels/bordo-koza.jpg",
    "${AssetsMenager.imagePath}/categories/Women_heels/bordo-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Women_heels/crne-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Women_heels/plave-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Women_heels/roze-koza.jpg",
  ];

  static List<String> menSneakersAssets = [
    "${AssetsMenager.imagePath}/categories/Men_sneakers/bele-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Men_sneakers/bez-tekstil.jpg",
    "${AssetsMenager.imagePath}/categories/Men_sneakers/bez.tekstil.jpg",
    "${AssetsMenager.imagePath}/categories/Men_sneakers/brain-skaj.jpg",
    "${AssetsMenager.imagePath}/categories/Men_sneakers/braon-koza.jpg",
    "${AssetsMenager.imagePath}/categories/Men_sneakers/crne-koza.jpg",
    "${AssetsMenager.imagePath}/categories/Men_sneakers/plave-tekstil.jpg",
  ];

  static List<String> menFlatAssets = [
    "${AssetsMenager.imagePath}/categories/Men_flat/bele-tekstil.jpg",
    "${AssetsMenager.imagePath}/categories/Men_flat/bez-tekstil.jpg",
    "${AssetsMenager.imagePath}/categories/Men_flat/braon-koza.jpg",
    "${AssetsMenager.imagePath}/categories/Men_flat/crne-koza.jpg",
    "${AssetsMenager.imagePath}/categories/Men_flat/crne-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Men_flat/plave-tekstil.jpg",
    "${AssetsMenager.imagePath}/categories/Men_flat/sivr-tekstil.jpg",
  ];

  static List<String> latestArrivalBrownAssets = [
    "${AssetsMenager.imagePath}/categories/Women_flat/braon-kozne.jpg",
    "${AssetsMenager.imagePath}/categories/Women_sneakers/braon-tektil.webp",
    "${AssetsMenager.imagePath}/categories/Men_sneakers/braon-koza.jpg",
    "${AssetsMenager.imagePath}/categories/Men_flat/braon-koza.jpg",
  ];

  static List<String> getCategoryAssets(String categoryId) {
    switch (categoryId) {
      case "women_flats":
        return womenFlatAssets;
      case "women_sneakers":
        return womenSneakersAssets;
      case "women_heels":
        return womenHeelsAssets;
      case "men_sneakers":
        return menSneakersAssets;
      case "men_flat_shoes":
        return menFlatAssets;
      default:
        return const [];
    }
  }

  static String titleFromId(String id) {
    final meta = _parseProductMeta(id);
    if (meta == null) {
      return "Zenske bele stikle";
    }
    return "${meta.gender} ${meta.color} ${meta.type}";
  }

  static String descriptionFromId(String id) {
    final meta = _parseProductMeta(id);
    if (meta == null) {
      return "Bele stikle od kvalitetnog materijala, peta 10cm.";
    }
    final colorCap = _capitalize(meta.color);
    final materialLabel = _materialLabelFromType(meta.materialType);
    final extra = meta.type == "stikle"
        ? "peta 10cm"
        : meta.type == "patike"
        ? "lagane i udobne"
        : "udobno gaziste";
    return "$colorCap ${meta.type} $materialLabel, $extra.";
  }

  static String categoryLabelFromId(String id) {
    return categoryLabelFromMeta(id: id);
  }

  static String categoryLabelFromMeta({
    String? gender,
    String? type,
    String? id,
  }) {
    final lowerId = id?.toLowerCase() ?? '';
    final normalizedGender = (gender ?? '').trim().toLowerCase();
    final normalizedType = (type ?? '').trim().toLowerCase();

    final resolvedGender = normalizedGender.isNotEmpty
        ? normalizedGender
        : lowerId.contains("women")
        ? "women"
        : lowerId.contains("men")
        ? "men"
        : "unisex";
    final resolvedType = normalizedType.isNotEmpty
        ? normalizedType
        : lowerId.contains("heels")
        ? "heels"
        : lowerId.contains("sneakers")
        ? "sneakers"
        : lowerId.contains("flat")
        ? "flat"
        : "shoes";

    final typeLabel = resolvedType == "flat" ? "flats" : resolvedType;
    return "$resolvedGender-$typeLabel";
  }

  static String categoryLabelFromLegacyId(String id) {
    final lower = id.toLowerCase();
    final gender = lower.contains("women")
        ? "women"
        : lower.contains("men")
        ? "men"
        : "unisex";
    final type = lower.contains("heels")
        ? "heels"
        : lower.contains("sneakers")
        ? "sneakers"
        : lower.contains("flat")
        ? "flats"
        : "shoes";
    return "$gender-$type";
  }

  static List<int> sizesFromId(String id) {
    final lower = id.toLowerCase();
    if (lower.contains("women")) {
      return [36, 37, 38, 39, 40, 41];
    }
    if (lower.contains("men")) {
      return [41, 42, 43, 44, 45, 46, 47, 48];
    }
    return [36, 37, 38, 39, 40, 41];
  }

  static const List<String> filterColors = [
    "bele",
    "crne",
    "braon",
    "plave",
    "roze",
    "zute",
    "bez",
    "sive",
    "bordo",
  ];

  static const List<String> filterGenders = ["women", "men"];
  static const List<String> filterTypes = ["flat", "heels", "sneakers"];
  static const List<String> materialTypes = ["koza", "skaj", "tekstil"];

  static String? colorFromId(String id) {
    final lower = id.toLowerCase();
    final tokens = RegExp(
      r"[a-z]+",
    ).allMatches(lower).map((m) => m[0]!).toList();
    for (final token in tokens) {
      final color = _colorFromToken(token);
      if (color != null) {
        return color;
      }
    }
    return null;
  }

  static String? materialTypeFromId(String id) {
    final lower = id.toLowerCase();
    final tokens = RegExp(
      r"[a-z]+",
    ).allMatches(lower).map((m) => m[0]!).toList();
    for (final token in tokens) {
      final materialType = _materialTypeFromToken(token);
      if (materialType != null) {
        return materialType;
      }
    }
    return null;
  }

  static String? genderFromId(String id) {
    final lower = id.toLowerCase();
    if (lower.contains("women")) {
      return "women";
    }
    if (lower.contains("men")) {
      return "men";
    }
    return null;
  }

  static String? typeFromId(String id) {
    final lower = id.toLowerCase();
    if (lower.contains("heels")) {
      return "heels";
    }
    if (lower.contains("sneakers")) {
      return "sneakers";
    }
    if (lower.contains("flat")) {
      return "flat";
    }
    return null;
  }

  static String colorLabel(String color) {
    return _capitalize(color);
  }

  static String genderLabel(String gender) {
    switch (gender) {
      case "women":
        return "Zensko";
      case "men":
        return "Musko";
      default:
        return gender;
    }
  }

  static String typeLabel(String type) {
    switch (type) {
      case "flat":
        return "Ravne";
      case "heels":
        return "Stikle";
      case "sneakers":
        return "Patike";
      default:
        return type;
    }
  }

  static String materialFilterLabel(String materialType) {
    switch (materialType) {
      case "koza":
        return "Prirodna koza";
      case "skaj":
        return "Vestacka koza";
      case "tekstil":
        return "Tekstil";
      default:
        return materialType;
    }
  }

  static double priceFromId(String id) {
    final meta = _parseProductMeta(id);
    final materialType = meta?.materialType;
    if (materialType == "koza") {
      return _priceFromSeed(id, const [10000, 10500, 11000, 11500, 12000]);
    }
    if (materialType == "skaj" || materialType == "tekstil") {
      return _priceFromSeed(id, const [
        7000,
        7500,
        8000,
        8500,
        9000,
        9500,
        10000,
      ]);
    }
    return _priceFromSeed(id, const [7000, 7500, 8000, 8500, 9000]);
  }

  static _ProductMeta? _parseProductMeta(String id) {
    final lower = id.toLowerCase();
    String? gender;
    if (lower.contains("women")) {
      gender = "Zenske";
    } else if (lower.contains("men")) {
      gender = "Muske";
    }

    String? type;
    if (lower.contains("heels")) {
      type = "stikle";
    } else if (lower.contains("sneakers")) {
      type = "patike";
    } else if (lower.contains("flat")) {
      type = "ravne cipele";
    }

    String? color;
    String? materialType;
    final tokens = RegExp(
      r"[a-z]+",
    ).allMatches(lower).map((m) => m[0]!).toList();
    for (final token in tokens) {
      color ??= _colorFromToken(token);
      materialType ??= _materialTypeFromToken(token);
    }

    if (gender == null || type == null || color == null) {
      final fallback = _fallbackFromId(id);
      gender ??= fallback.gender;
      type ??= fallback.type;
      color ??= fallback.color;
      materialType ??= fallback.materialType;
    }

    return _ProductMeta(
      gender: gender,
      color: color,
      type: type,
      materialType: materialType ?? "tekstil",
    );
  }

  static _ProductMeta _fallbackFromId(String id) {
    final indexMatch = RegExp(r"\d+").firstMatch(id);
    final index = indexMatch != null ? int.parse(indexMatch.group(0)!) : 0;
    const genders = ["Zenske", "Muske"];
    const types = ["stikle", "patike", "ravne cipele"];
    const colors = [
      "bele",
      "crne",
      "braon",
      "plave",
      "roze",
      "zute",
      "bez",
      "sive",
      "bordo",
    ];
    final gender = genders[index % genders.length];
    final type = types[index % types.length];
    final color = colors[index % colors.length];
    return _ProductMeta(
      gender: gender,
      color: color,
      type: type,
      materialType: "tekstil",
    );
  }

  static String? _colorFromToken(String token) {
    switch (token) {
      case "bele":
      case "bela":
        return "bele";
      case "crne":
      case "crna":
        return "crne";
      case "braon":
        return "braon";
      case "plave":
      case "plava":
        return "plave";
      case "roze":
        return "roze";
      case "zute":
      case "zuta":
        return "zute";
      case "bez":
        return "bez";
      case "sivr":
      case "sive":
        return "sive";
      case "bordo":
        return "bordo";
      default:
        return null;
    }
  }

  static String? _materialTypeFromToken(String token) {
    switch (token) {
      case "koza":
      case "kozne":
        return "koza";
      case "skaj":
        return "skaj";
      case "tekstil":
        return "tekstil";
      default:
        return null;
    }
  }

  static String _materialLabelFromType(String? materialType) {
    switch (materialType) {
      case "koza":
        return "od prirodne koze";
      case "skaj":
        return "od vestacke koze";
      case "tekstil":
        return "od tekstila";
      default:
        return "od kvalitetnog materijala";
    }
  }

  static double _priceFromSeed(String seed, List<int> values) {
    var sum = 0;
    for (final unit in seed.codeUnits) {
      sum += unit;
    }
    return values[sum % values.length].toDouble();
  }

  static String _capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }
}

class _ProductMeta {
  _ProductMeta({
    required this.gender,
    required this.color,
    required this.type,
    required this.materialType,
  });

  final String gender;
  final String color;
  final String type;
  final String materialType;
}
