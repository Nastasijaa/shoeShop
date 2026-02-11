import 'package:uuid/uuid.dart';

class ProductModel {
  final String productId;
  final String productTitle;
  final String productPrice;
  final String productCategory;
  final String productDescription;
  final String productImage;
  final String productQuantity;
  final String productGender;
  final String productColor;
  final String productMaterial;

  ProductModel({
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.productCategory,
    required this.productDescription,
    required this.productImage,
    required this.productQuantity,
    required this.productGender,
    required this.productColor,
    required this.productMaterial,
  });

  factory ProductModel.withUuid({
    required String productTitle,
    required String productPrice,
    required String productCategory,
    required String productDescription,
    required String productImage,
    required String productQuantity,
    required String productGender,
    required String productColor,
    required String productMaterial,
  }) {
    return ProductModel(
      productId: const Uuid().v4(),
      productTitle: productTitle,
      productPrice: productPrice,
      productCategory: productCategory,
      productDescription: productDescription,
      productImage: productImage,
      productQuantity: productQuantity,
      productGender: productGender,
      productColor: productColor,
      productMaterial: productMaterial,
    );
  }
}
