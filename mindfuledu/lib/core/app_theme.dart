import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF141414);
  static const paper = Color(0xFFFCFCFB);
  static const surface = Color(0xFFFFFFFF);
  static const olive = Color(0xFF3E735B);
  static const moss = Color(0xFF3E735B);
  static const mint = Color(0xFFEAF4EF);
  static const muted = Color(0xFF61635F);
  static const line = Color(0xFFE9ECE8);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: olive,
      brightness: Brightness.light,
      primary: ink,
      secondary: moss,
      surface: surface,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFF0F1EF)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: mint,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? olive : muted,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: olive, width: 1.3),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: olive,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: olive,
          side: const BorderSide(color: line),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: olive),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF4F5F3),
        selectedColor: mint,
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: ink),
        headlineSmall: TextStyle(fontWeight: FontWeight.w900, color: ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w800, color: ink),
        bodyLarge: TextStyle(color: ink, height: 1.45),
        bodyMedium: TextStyle(color: ink, height: 1.45),
        bodySmall: TextStyle(color: muted, height: 1.35),
      ),
    );
  }
}
