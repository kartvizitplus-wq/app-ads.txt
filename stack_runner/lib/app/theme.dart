import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7DF9FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF04050F),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
}
