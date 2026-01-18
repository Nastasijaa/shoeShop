import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/screens/cart/checkout_screen.dart';
import 'package:shoeshop/services/user_prefs.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class CartBottomSheetWidget extends StatelessWidget {
  const CartBottomSheetWidget ({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Container(
decoration: BoxDecoration(
color: Theme.of(context).scaffoldBackgroundColor,
border: const Border(
top: BorderSide(width: 1, color: Colors.grey),
),
),
child: Padding(
padding: const EdgeInsets.all(8.0),
child: SizedBox(
height: kBottomNavigationBarHeight + 10,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Flexible(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
FittedBox(
child: TitelesTextWidget(
label:
    "Total (${cartProvider.itemCount} products/${cartProvider.totalQuantity} items)")),
SubtitleTextWidget(
label: "${cartProvider.totalPrice.toStringAsFixed(2)} RSD",
color: AppColors.darkPrimary,
),
],
),
),
ElevatedButton(
onPressed: () async {
  if (await UserPrefs.isGuest()) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Guest users cannot like, add to cart, or purchase. Please log in.",
        ),
      ),
    );
    return;
  }
  if (!context.mounted) {
    return;
  }
  Navigator.pushNamed(context, CheckoutScreen.routeName);
},
child: const Text("Checkout"),
),
],
),
),
),
);

  }
}
