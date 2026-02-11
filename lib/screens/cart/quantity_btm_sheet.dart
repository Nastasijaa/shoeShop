import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';

class QuantitySheetBottomWidget extends StatelessWidget {
  const QuantitySheetBottomWidget({
    super.key,
    required this.currentQuantity,
    this.maxQuantity = 10,
  });

  final int currentQuantity;
  final int maxQuantity;

  @override
  Widget build(BuildContext context) {
   return Column(
children: [
const SizedBox(
height: 20,
),
Container(
height: 6,
width: 50,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(12.0),
color: Colors.grey,
),
),
const SizedBox(
height: 20,
),
Expanded(
child: ListView.builder(
// physics: NeverScrollableScrollPhysics(),
// shrinkWrap: true,
itemCount: maxQuantity,
itemBuilder: (context, index) {
final qty = index + 1;
return InkWell(
onTap: () {
log("index $index");
Navigator.pop(context, qty);
},
child: Center(
child: Padding(
padding: const EdgeInsets.all(4.0),
child: SubtitleTextWidget(
  label: "$qty",
  fontWeight: qty == currentQuantity ? FontWeight.bold : FontWeight.normal,
),
)),
);
}),
),
],
);
  }
}
