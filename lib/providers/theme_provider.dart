import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const theme_status= "theme_status";
  bool darkTheme= false; //kad se pokrene aplikacija da bude bela
  bool get getIsDarkTheme => darkTheme;

  ThemeProvider(){
    getTheme();
  }
  
setDarkTheme({required bool themeValue}) async {
    SharedPreferences pref= await SharedPreferences.getInstance();
    pref.setBool(theme_status, themeValue);
    darkTheme=themeValue;
    notifyListeners();
  }
  Future<bool> getTheme() async {
    SharedPreferences pref= await SharedPreferences.getInstance();
  darkTheme = pref.getBool(theme_status) ?? false;
    notifyListeners();
    return darkTheme;
  }

}