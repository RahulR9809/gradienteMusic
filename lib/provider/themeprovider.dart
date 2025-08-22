import 'package:yourappname/utils/constant.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool get isDarkMode => Constant.isDark;

  ThemeMode get themeMode => Constant.isDark ? ThemeMode.dark : ThemeMode.light;

  void changeTheme(bool isOn) {
    Constant.isDark = isOn;
    notifyListeners();
  }
}
