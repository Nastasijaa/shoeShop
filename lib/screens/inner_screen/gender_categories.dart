import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/modals/categories_model.dart';
import 'package:shoeshop/widgets/ctg_rounded_widget.dart';
import 'package:shoeshop/widgets/title_text.dart';

class GenderCategoriesScreen extends StatefulWidget {
  const GenderCategoriesScreen({
    super.key,
    required this.title,
    required this.categories,
  });

  final String title;
  final List<CategoriesModel> categories;

  @override
  State<GenderCategoriesScreen> createState() => _GenderCategoriesScreenState();
}

class _GenderCategoriesScreenState extends State<GenderCategoriesScreen> {
  int _selectedColorIndex = 0;

  final List<Map<String, dynamic>> _colorFilters = const [
    {'label': 'All', 'color': null},
    {'label': 'Black', 'color': Colors.black},
    {'label': 'White', 'color': Colors.white},
    {'label': 'Red', 'color': Colors.red},
    {'label': 'Blue', 'color': Colors.blue},
    {'label': 'Green', 'color': Colors.green},
    {'label': 'Brown', 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: TitelesTextWidget(label: widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colorFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _colorFilters[index];
                  final color = item['color'] as Color?;
                  final isSelected = index == _selectedColorIndex;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (color != null)
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Colors.white54 : Colors.black54,
                                width: 1,
                              ),
                            ),
                          ),
                        if (color != null) const SizedBox(width: 6),
                        Text(item['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: List.generate(widget.categories.length, (index) {
                  final category = widget.categories[index];
                  return CategoryRoundedWidget(
                    name: category.name,
                    image: category.image,
                    icon: category.icon,
                    onTap: () {},
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
