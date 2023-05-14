import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData.dark().copyWith(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 19, 62, 41),
  ),
  textTheme: GoogleFonts.ralewayTextTheme(),
  scaffoldBackgroundColor: const Color.fromARGB(255, 39, 56, 40),
);
