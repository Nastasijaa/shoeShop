import 'package:flutter/material.dart';

class TitelesTextWidget extends StatelessWidget {
  const TitelesTextWidget({
    super.key,
    required this.label, //requred jer text menjamo
    this.fontSize=20,
    this.color,
    this.maxLines
  });

  final String label;
  final double fontSize;
  final Color? color;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return  Text(
      label, //dobije iz druge kalse
      maxLines: maxLines,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
        overflow: TextOverflow.ellipsis
      )
    );
  }
}