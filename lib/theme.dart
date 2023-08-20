import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightThemeData = ThemeData(
  scaffoldBackgroundColor: const Color(0xffF5F5FA),
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 0, 118, 182),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
  appBarTheme: const AppBarTheme(
    color: Color(0xffF5F5FA),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  floatingActionButtonTheme:
      const FloatingActionButtonThemeData(foregroundColor: Colors.white),
);
