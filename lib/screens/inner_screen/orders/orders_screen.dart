import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoeshop/consts/admin_config.dart';
import 'package:shoeshop/screens/inner_screen/orders/orders_widget.dart';
import 'package:shoeshop/screens/root_screen.dart';
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
  late final User? _currentUser;
  bool _isAdmin = false;
  bool _didResolveRouteArgs = false;
  bool _useTopLevelFallback = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _isAdmin = AdminConfig.isAdminEmail(_currentUser?.email ?? "");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResolveRouteArgs) {
      return;
    }
    _didResolveRouteArgs = true;
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic>) {
      final forcedAdmin = routeArgs["isAdminView"] == true;
      if (forcedAdmin) {
        _isAdmin = true;
      }
    }
  }

  Query<Map<String, dynamic>>? get _query {
    if (_currentUser == null) {
      return null;
    }
    if (_isAdmin) {
      return FirebaseFirestore.instance
          .collection("orders")
          .orderBy("createdAt", descending: true);
    }
    if (_useTopLevelFallback) {
      return FirebaseFirestore.instance
          .collection("orders")
          .where("userId", isEqualTo: _currentUser.uid);
    }
    return FirebaseFirestore.instance
        .collection("users")
        .doc(_currentUser.uid)
        .collection("orders")
        .orderBy("createdAt", descending: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_query == null) {
      return Scaffold(
        appBar: AppBar(title: const TitelesTextWidget(label: 'Placed orders')),
        body: EmptyBagWidget(
          imagePath: "${AssetsMenager.imagePath}/bag/checkout.png",
          title: "Prijavi se da vidis porudzbine",
          subtitle: "",
          buttonText: "Shop now",
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(RootScreen.routeName);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const TitelesTextWidget(label: 'Placed orders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _query!.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            if (error is FirebaseException) {
              if (!_isAdmin &&
                  !_useTopLevelFallback &&
                  error.code == "permission-denied") {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || _useTopLevelFallback) {
                    return;
                  }
                  setState(() {
                    _useTopLevelFallback = true;
                  });
                });
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Text("Greska pri ucitavanju orders: ${error.code}"),
              );
            }
            return const Center(child: Text("Greska pri ucitavanju orders."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...(snapshot.data?.docs ?? const [])];
          if (!_isAdmin && _useTopLevelFallback) {
            docs.sort((a, b) {
              final aTs = a.data()["createdAt"] as Timestamp?;
              final bTs = b.data()["createdAt"] as Timestamp?;
              final aMs = aTs?.millisecondsSinceEpoch ?? 0;
              final bMs = bTs?.millisecondsSinceEpoch ?? 0;
              return bMs.compareTo(aMs);
            });
          }
          if (docs.isEmpty) {
            return EmptyBagWidget(
              imagePath: "${AssetsMenager.imagePath}/bag/checkout.png",
              title: "No orders has been placed yet",
              subtitle: "",
              buttonText: "Shop now",
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(RootScreen.routeName);
              },
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: OrdersWidget(
                  orderDoc: docs[index],
                  isAdmin: _isAdmin,
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 2);
            },
          );
        },
      ),
    );
  }
}
