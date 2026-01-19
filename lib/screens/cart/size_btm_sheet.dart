import 'package:flutter/material.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class SizeSheetBottomWidget extends StatelessWidget {
  const SizeSheetBottomWidget({
    super.key,
    required this.sizes,
    this.currentSize,
  });

  final List<int> sizes;
  final int? currentSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 6,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        const TitelesTextWidget(label: "Izaberi broj obuce"),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: sizes.length,
            itemBuilder: (context, index) {
              final size = sizes[index];
              return InkWell(
                onTap: () {
                  Navigator.pop(context, size);
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: SubtitleTextWidget(
                      label: "$size",
                      fontWeight:
                          size == currentSize ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
