import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LyftMateAppTheme {

  LyftMateAppTheme._();

  static ThemeData lightTheme = ThemeData(
    // useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.poppins().fontFamily,
    // elevatedButtonTheme: ElevatedButtonThemeData()
    // textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.deepOrange)),
    //   textTheme: Theme.of(context).textTheme.apply(
    //       fontFamily: 'Open Sans',
    //       bodyColor: Colors.white,
    //       displayColor: Colors.white)
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );
}