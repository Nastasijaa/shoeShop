import 'package:flutter/material.dart';
import 'package:shoeshop/modals/categories_model.dart';
import 'package:shoeshop/services/assets_menager.dart';

class AppConstants {
  static const String imageUrl =
      'https://www.adidas.com/us/shoes';

  static List<String> bannersImages = [
    "${AssetsMenager.imagePath}/banners/shop.jpg",
    "${AssetsMenager.imagePath}/banners/shop2.jpg",
  ];

  static List<CategoriesModel> categoriesList = [
    CategoriesModel(
      id: "men",
      name: "Men",
      icon: Icons.male,
    ),
    CategoriesModel(
      id: "women",
      name: "Women",
      icon: Icons.female,
    ),
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
}
