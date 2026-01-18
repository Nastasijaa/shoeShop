import 'package:flutter/material.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class OrdersWidget extends StatelessWidget {
  const OrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.asset(
              "${AssetsMenager.imagePath}/bag/checkout.png",
              height: 48,
              width: 48,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitelesTextWidget(label: "Order #1024", fontSize: 16),
                  SizedBox(height: 4),
                  SubtitleTextWidget(
                    label: "2 items - \$59.99",
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
