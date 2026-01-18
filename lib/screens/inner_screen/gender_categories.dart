import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/modals/categories_model.dart';
import 'package:shoeshop/widgets/ctg_rounded_widget.dart';
import 'package:shoeshop/widgets/title_text.dart';

class GenderCategoriesScreen extends StatelessWidget {
  const GenderCategoriesScreen({
    super.key,
    required this.title,
    required this.categories,
  });

  final String title;
  final List<CategoriesModel> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TitelesTextWidget(label: title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(categories.length, (index) {
            final category = categories[index];
            return CategoryRoundedWidget(
              name: category.name,
              image: category.image,
              icon: category.icon,
              onTap: () {},
            );
          }),
        ),
      ),
    );
  }
}
