import 'package:flutter/material.dart';
import 'package:fonyat/constants.dart';
import 'package:sizer/sizer.dart';

ThemeData darkThemeData() {
  return ThemeData.dark().copyWith(
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kBackgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: kBackgroundColor),
    cardColor: kPrimaryColor,
    outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: MaterialStatePropertyAll(kPrimaryColor),
          side: MaterialStatePropertyAll(BorderSide(color: kPrimaryColor)),
          foregroundColor: MaterialStatePropertyAll(Colors.white),
          elevation: MaterialStatePropertyAll(1),
          padding: MaterialStatePropertyAll(EdgeInsets.zero)
        )
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kBackgroundColor,
      selectedItemColor: kButtonColor,
      unselectedItemColor: kUnselectedButtonColor,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      showUnselectedLabels: true,
    ),
  );
}
