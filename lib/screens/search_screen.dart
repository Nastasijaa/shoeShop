import 'package:flutter/material.dart';
import 'package:shoeshop/widgets/title_text.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: TitelesTextWidget(label: "Sreach Screen"),)
    );
  }
}