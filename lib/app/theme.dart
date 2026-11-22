import 'package:flutter/material.dart';

/// The Maker's Market palette: fired clay, Akhmim indigo and sand, with
/// olive and saffron from the crafts themselves.
const clay = Color(0xFFB5532C);
const indigo = Color(0xFF2E3A59);
const sand = Color(0xFFF3EADB);
const olive = Color(0xFF6B7A3A);
const saffron = Color(0xFFD9A441);
const ink = Color(0xFF2A211C);

// Older names, kept so existing widgets read naturally.
const brand = clay;
const coral = clay;
const gold = saffron;

/// Display face (Fraunces, Amiri for Arabic) for titles and prices.
const display = 'Fraunces';
const displayFallback = ['Amiri'];

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? const Color(0xFF1C1714) : sand;
  final card = dark ? const Color(0xFF2A2420) : const Color(0xFFFFFBF5);
  final onSurface = dark ? const Color(0xFFF3EADB) : ink;
  final scheme = ColorScheme.fromSeed(seedColor: clay, brightness: brightness).copyWith(
    primary: dark ? const Color(0xFFE08A62) : clay,
    onPrimary: dark ? ink : Colors.white,
    secondary: dark ? const Color(0xFF9DB0D8) : indigo,
    tertiary: olive,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: dark ? const Color(0xFFC7B9A6) : const Color(0xFF6E5F52),
    outlineVariant: dark ? const Color(0xFF3B322C) : const Color(0xFFE3D5C1),
    primaryContainer: dark ? const Color(0xFF4A2A1C) : const Color(0xFFF2D9C9),
    onPrimaryContainer: dark ? const Color(0xFFF7D9C8) : const Color(0xFF5A2410),
  );

  final base = ThemeData(useMaterial3: true, brightness: brightness);
  final text = base.textTheme.apply(
    fontFamily: 'WorkSans',
    fontFamilyFallback: const ['ReadexPro'],
    bodyColor: onSurface,
    displayColor: onSurface,
  );
  TextStyle? serif(TextStyle? s, {double? size}) =>
      s?.copyWith(fontFamily: display, fontFamilyFallback: displayFallback, fontWeight: FontWeight.w600, fontSize: size, letterSpacing: -0.2);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    textTheme: text.copyWith(
      displaySmall: serif(text.displaySmall),
      headlineMedium: serif(text.headlineMedium),
      headlineSmall: serif(text.headlineSmall),
      titleLarge: serif(text.titleLarge, size: 22),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: display,
        fontFamilyFallback: displayFallback,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: scheme.outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: scheme.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: scheme.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontFamily: 'WorkSans', fontFamilyFallback: ['ReadexPro'], fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: .2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: card,
      selectedColor: dark ? const Color(0xFF4A2A1C) : indigo,
      labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      checkmarkColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ),
    navigationRailTheme: NavigationRailThemeData(backgroundColor: card, indicatorColor: scheme.primaryContainer),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
