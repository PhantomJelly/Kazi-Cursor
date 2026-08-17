import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

class KaziTheme {
  KaziTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: KaziColors.background,
      colorScheme: const ColorScheme.light(
        primary: KaziColors.primary,
        onPrimary: KaziColors.onPrimary,
        surface: KaziColors.white,
        onSurface: KaziColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KaziColors.white,
        foregroundColor: KaziColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      fontFamily: 'Roboto',
    );
  }
}
