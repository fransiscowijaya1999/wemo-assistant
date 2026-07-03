import 'package:flutter/material.dart';

/// App theme. Shop-floor UX: high contrast, big touch targets, works
/// one-handed. Brand color matches the admin web app ("wemo amber").
///
/// Gotcha (found in M6): the FilledButton minimumSize below is full-width by
/// design for the big primary actions — inside a Row, wrap the button in
/// Expanded/Flexible or it silently breaks layout.
class AppTheme {
  /// Mantine orange[6] — the admin theme's primary shade.
  static const brand = Color(0xFFFD7E14);

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: brand, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.comfortable,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
