import 'package:flutter/material.dart';

class CategoriesModel {
  final String id;
  final String name;
  final String? image;
  final IconData? icon;

  CategoriesModel({
    required this.id,
    required this.name,
    this.image,
    this.icon,
  });
}
