import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:shoeshop/screens/Home_screen.dart';
import 'package:shoeshop/screens/cart_screen.dart';
import 'package:shoeshop/screens/profile_screen.dart';
import 'package:shoeshop/screens/search_screen.dart';
//stateful jer menja stanje ostali screen su stateless jer ne menjaju druga stanja

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<RootScreen> {
  late List <Widget> screens; //late jer znamo da cemo ga sigurno koristiit
  int currentScreen=0; //stavicemo home screen na 0 da bi se uvek otvorio home screen koji je na indexu 0
  late PageController controller;

  @override
  void initState() {
    super.initState();
    screens= const [
      //bitan redosled zbog indexa
      HomeScreen(),
      SearchScreen(),
      CartScreen(),
      ProfileScreen(),

    ];
    controller = PageController(initialPage: currentScreen); //na osnovu trenutnog menja
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(), //da s ene skroluje prstima
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        height: kBottomNavigationBarHeight,
        onDestinationSelected: (index){
        setState(() {
        currentScreen=index;
      });
      controller.jumpToPage(currentScreen);
      },
      destinations: const [
        NavigationDestination(
        selectedIcon: Icon(IconlyBold.home),  //da e vidi razlika kada kliknemo na nju boja npr 
        icon: Icon(IconlyLight.home),
        label: "Home",
          ),
           NavigationDestination(
        selectedIcon: Icon(IconlyBold.search),  //da e vidi razlika kada kliknemo na nju boja npr 
        icon: Icon(IconlyLight.search),
        label: "Search",
          ),
           NavigationDestination(
        selectedIcon: Icon(IconlyBold.bag2),  //da e vidi razlika kada kliknemo na nju boja npr 
        icon: Icon(IconlyLight.bag2),
        label: "Cart",
          ),
           NavigationDestination(
        selectedIcon: Icon(IconlyBold.profile),  //da e vidi razlika kada kliknemo na nju boja npr 
        icon: Icon(IconlyLight.profile),
        label: "Profile",
          ),
      ],
      ),
    );
  }
}