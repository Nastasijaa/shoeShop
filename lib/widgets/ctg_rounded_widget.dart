import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';

class CategoryRoundedWidget extends StatelessWidget {
  const CategoryRoundedWidget({
    super.key,
    this.image,
    required this.name,
    this.icon,
    this.onTap,
  });
  final String? image;
  final String name;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          if (icon != null)
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                icon,
                size: 28,
                color: AppColors.darkPrimary,
              ),
            )
          else if (image != null)
            ClipOval(
              child: Image.asset(
                image!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            )
          else
            const SizedBox(height: 50, width: 50),
          const SizedBox(height: 5),
          SubtitleTextWidget(
            label: name,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.lightPrimary : AppColors.darkPrimary,
          ),
        ],
      ),
    );
  }
}
