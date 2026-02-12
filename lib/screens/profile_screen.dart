import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/admin_config.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/providers/theme_provider.dart';
import 'package:shoeshop/screens/inner_screen/orders/orders_screen.dart';
import 'package:shoeshop/screens/inner_screen/viewed_recently.dart';
import 'package:shoeshop/screens/inner_screen/wishlist.dart';
import 'package:shoeshop/screens/inner_screen/address_screen.dart';
import 'package:shoeshop/screens/admin/admin_dashboard_screen.dart';
import 'package:shoeshop/screens/auth/login.dart';
import 'package:shoeshop/screens/root_screen.dart';
import 'package:shoeshop/services/auth_service.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/services/my_app_function.dart';
import 'package:shoeshop/services/user_prefs.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Guest";
  String _email = "guest@example.com";
  String _imagePath = "";
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserPrefs.getUser();
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoggedIn =
          (user['name']?.isNotEmpty ?? false) ||
          (user['email']?.isNotEmpty ?? false);
      _name = (user['name']?.isNotEmpty ?? false) ? user['name']! : _name;
      _email = (user['email']?.isNotEmpty ?? false) ? user['email']! : _email;
      _imagePath = user['imagePath'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isAdmin = _isLoggedIn && AdminConfig.isAdminEmail(_email);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(child: Image.asset(AssetsMenager.logo)),
        ),
        title: const Text("Profile Screen"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: _isLoggedIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: _imagePath.isNotEmpty
                              ? FileImage(File(_imagePath))
                              : const NetworkImage(
                                      "https://cdn.pixabay.com/photo/2017/11/10/05/48/user-2935527_1280.png",
                                    )
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitelesTextWidget(label: _name),
                        SubtitleTextWidget(label: _email),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: isAdmin,
                    child: CustomListTile(
                      leadingIcon: Icons.admin_panel_settings_outlined,
                      text: "Admin Dashboard",
                      function: () {
                        Navigator.pushNamed(
                          context,
                          AdminDashboardScreen.routeName,
                        );
                      },
                    ),
                  ),
                  if (isAdmin) const SizedBox(height: 6),
                  const TitelesTextWidget(label: "General"),
                  const SizedBox(height: 10),
                  CustomListTile(
                    imagePath: "${AssetsMenager.imagePath}/bag/checkout.png",
                    text: "All Orders",
                    function: () {
                      Navigator.pushNamed(
                        context,
                        OrdersScreen.routeName,
                        arguments: {"isAdminView": isAdmin},
                      );
                    },
                  ),
                  CustomListTile(
                    imagePath: "${AssetsMenager.imagePath}/bag/wishlist.png",
                    text: "Wishlist",
                    function: () {
                      Navigator.pushNamed(context, WishlistScreen.routName);
                    },
                  ),
                  CustomListTile(
                    imagePath: "${AssetsMenager.imagePath}/profile/repeat.png",
                    text: "Viewed Recently",
                    function: () {
                      Navigator.pushNamed(
                        context,
                        ViewedRecentlyScreen.routName,
                      );
                    },
                  ),
                  CustomListTile(
                    imagePath: "${AssetsMenager.imagePath}/address.png",
                    text: "Address",
                    function: () {
                      Navigator.pushNamed(context, AddressScreen.routeName);
                    },
                  ),
                  const SizedBox(height: 6),
                  const Divider(),
                  const SizedBox(height: 10),
                  const TitelesTextWidget(label: "Settings"),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    secondary: Image.asset(
                      "${AssetsMenager.imagePath}/profile/night-mode.png",
                      height: 34,
                    ),
                    title: Text(
                      themeProvider.getIsDarkTheme
                          ? "Dark Theme"
                          : "Light Theme",
                    ),
                    value: themeProvider.getIsDarkTheme,
                    onChanged: (value) {
                      themeProvider.setDarkTheme(themeValue: value);
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),

                icon: Icon(
                  _isLoggedIn ? Icons.logout : Icons.login,
                  color: Colors.white,
                ),
                label: Text(
                  _isLoggedIn ? "Logout" : "Login",
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (!_isLoggedIn) {
                    if (!mounted) {
                      return;
                    }
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(LoginScreen.routeName);
                    return;
                  }
                  await MyAppFunctions.showErrorOrWarningDialog(
                    context: context,
                    subtitle: "Are you sure you want to sign out?",
                    isError: false,
                    fct: () {
                      UserPrefs.setGuest().then((_) {
                        if (!mounted) {
                          return;
                        }
                        AuthService.applyGuestSession(
                          context,
                          clearGuestData: true,
                        );
                        setState(() {
                          _isLoggedIn = false;
                          _name = "Guest";
                          _email = "guest@example.com";
                        });
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(RootScreen.routeName);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    this.imagePath,
    this.leadingIcon,
    required this.text,
    required this.function,
  }) : assert(
         imagePath != null || leadingIcon != null,
         "Either imagePath or leadingIcon must be provided.",
       );
  final String? imagePath;
  final IconData? leadingIcon;
  final String text;
  final Function function;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: () {
        function();
      },
      title: SubtitleTextWidget(label: text),
      leading: imagePath != null
          ? Image.asset(
              imagePath!,
              height: 34,
              color: isDarkMode ? Colors.white : null,
            )
          : Icon(
              leadingIcon,
              size: 30,
              color: isDarkMode ? Colors.white : AppColors.darkPrimary,
            ),
      trailing: Icon(
        IconlyLight.arrowRight2,
        color: isDarkMode ? Colors.white : null,
      ),
    );
  }
}
