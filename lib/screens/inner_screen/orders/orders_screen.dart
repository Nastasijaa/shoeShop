import 'package:flutter/material.dart';
import 'package:shoeshop/screens/inner_screen/orders/orders_widget.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/empty_bag.dart';
import 'package:shoeshop/widgets/title_text.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/OrderScreen';
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isEmptyOrders = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TitelesTextWidget(label: 'Placed orders')),
      body: isEmptyOrders
          ? EmptyBagWidget(
              imagePath: "${AssetsMenager.imagePath}/bag/checkout.png",
              title: "No orders has been placed yet",
              subtitle: "",
              buttonText: "Shop now",
            )
          : ListView.separated(
              itemCount: 15,
              itemBuilder: (ctx, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  child: OrdersWidget(),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  // thickness: 8,
                  // color: Colors.red,
                );
              },
            ),
    );
  }
}
