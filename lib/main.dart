import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/theme_data.dart';
import 'package:shoeshop/providers/theme_provider.dart';
import 'package:shoeshop/screens/auth/login.dart';
import 'package:shoeshop/screens/auth/register.dart';
import 'package:shoeshop/screens/inner_screen/orders/orders_screen.dart';
import 'package:shoeshop/screens/inner_screen/product_details.dart';
import 'package:shoeshop/screens/inner_screen/viewed_recently.dart';
import 'package:shoeshop/screens/inner_screen/wishlist.dart';
import 'package:shoeshop/providers/wishlist_provider.dart';
import 'package:shoeshop/screens/root_screen.dart';

void main() {
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
            },
          );
        },
      ),
    );
  }
}
