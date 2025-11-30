import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.teal,
  scaffoldBackgroundColor: const Color(0xFFF7F9FA),
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
  ),
);
