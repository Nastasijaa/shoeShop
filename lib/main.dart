import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/stripe_config.dart';
import 'package:shoeshop/consts/theme_data.dart';
import 'package:shoeshop/firebase_options.dart';
import 'package:shoeshop/providers/theme_provider.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/providers/viewed_recently_provider.dart';
import 'package:shoeshop/screens/auth/login.dart';
import 'package:shoeshop/screens/auth/register.dart';
import 'package:shoeshop/screens/admin/admin_dashboard_screen.dart';
import 'package:shoeshop/screens/admin/admin_products_manage_screen.dart';
import 'package:shoeshop/screens/cart/checkout_screen.dart';
import 'package:shoeshop/screens/inner_screen/orders/orders_screen.dart';
import 'package:shoeshop/screens/inner_screen/product_details.dart';
import 'package:shoeshop/screens/inner_screen/viewed_recently.dart';
import 'package:shoeshop/screens/inner_screen/wishlist.dart';
import 'package:shoeshop/providers/wishlist_provider.dart';
import 'package:shoeshop/screens/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (StripeConfig.hasValidPublishableKey) {
    try {
      Stripe.publishableKey = StripeConfig.publishableKey;
      Stripe.merchantIdentifier = StripeConfig.merchantIdentifier;
      await Stripe.instance
          .applySettings()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("Stripe init skipped: $e");
    }
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return WishlistProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return CartProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return ViewedRecentlyProvider();
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ShoeShop',
            theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTheme,
              context: context,
            ),
            home: const LoginScreen(),

            routes: {
              RootScreen.routeName: (context) => const RootScreen(),
              ProductDetailsScreen.routName: (context) =>
                  const ProductDetailsScreen(),
              WishlistScreen.routName: (context) => const WishlistScreen(),
              ViewedRecentlyScreen.routName: (context) =>
                  const ViewedRecentlyScreen(),
              RegisterScreen.routName: (context) => const RegisterScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              OrdersScreen.routeName: (context) => const OrdersScreen(),
              CheckoutScreen.routeName: (context) => const CheckoutScreen(),
              AdminDashboardScreen.routeName: (context) =>
                  const AdminDashboardScreen(),
              AdminProductsManageScreen.routeName: (context) =>
                  const AdminProductsManageScreen(),
            },
          );
        },
      ),
    );
  }
}
