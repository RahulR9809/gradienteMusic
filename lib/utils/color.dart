import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/* Main Color Start */
const colorPrimary = Color(0xFFFF452D);
const colorPrimaryDark = Color(0xFFFF452D);
const colorAccent = Color(0xFF71828A);
/* Main Color End */

const appBgColor = Color(0xffF5F5F5);
const subscriptionBG = Color.fromARGB(255, 12, 3, 2);
const white = Color(0xffffffff);
const black = Color(0xff000000);
const gray = Color(0xff878787);
const lightgray = Color(0xffD3D3D3);
const transparent = Colors.transparent;

/* ============================= Light Theme =============================== */

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  /* Main Color Start */
  primaryColor: colorPrimary,
  secondaryHeaderColor: colorPrimary.withValues(alpha: 0.08),
  hintColor: colorAccent,
  scaffoldBackgroundColor: appBgColor,
  /* Main Color End */
  /* Text Color Start */
  colorScheme: const ColorScheme.light(
    surface: black,
    primary: white,
    onPrimary: white,
    secondary: white,
    onSecondary: white,
  ),
  /* Text Color End */
  appBarTheme: const AppBarTheme(
      color: white,
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark)),
  cardColor: white,
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: white,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: white,
  ),
);

/* ============================= Dark Theme =============================== */

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  /* Main Color Start */
  primaryColor: colorPrimary,
  hintColor: colorAccent,
  secondaryHeaderColor: gray.withValues(alpha: 0.20),
  scaffoldBackgroundColor: black,
  /* Main Color End */
  /* Text Color Start */

  colorScheme: const ColorScheme.dark(
    surface: white,
    primary: white,
    onPrimary: white,
    secondary: white,
    onSecondary: white,
  ),
  /* Text Color End */
  appBarTheme: const AppBarTheme(
    color: black,
    systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: black,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light),
  ),
  cardColor: black,
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: black,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: black,
  ),
);
