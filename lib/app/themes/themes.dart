import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CricketSpiritColors {
  CricketSpiritColors._();

  // Core colors
  static const Color background = Color(0xFF0f1729);
  static const Color foreground = Color(0xFFF8FAFC);
  static const Color card = Color(0xFF1E293B);
  static const Color cardForeground = Color(0xFFF8FAFC);

  // Accents
  static const Color primary = Color(0xFFCDFF2F);
  static const Color primaryForeground = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF374151);
  static const Color secondaryForeground = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF374151);
  static const Color mutedForeground = Color(0xFF94A3B8);

  // Border/input
  static const Color border = Color(0xFF334155);
  static const Color input = Color(0xFF334155);
  static const Color ring = Color(0xFFCDFF2F);
  static const Color white10 = Color(0x1AFFFFFF);

  // Semantic
  static const Color error = Color(0xFFEF4444);
}

class CricketSpiritRadius {
  CricketSpiritRadius._();

  static const double button = 8;
  static const double card = 12;
  static const double input = 8;
  static const double dialog = 8;
}

ThemeData cricketSpiritTheme() {
  final baseTextColor = CricketSpiritColors.foreground;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: CricketSpiritColors.primary,
      onPrimary: CricketSpiritColors.primaryForeground,
      secondary: CricketSpiritColors.secondary,
      onSecondary: CricketSpiritColors.secondaryForeground,
      surface: CricketSpiritColors.card,
      onSurface: CricketSpiritColors.cardForeground,
      error: CricketSpiritColors.error,
      onError: CricketSpiritColors.foreground,
    ),
    scaffoldBackgroundColor: CricketSpiritColors.background,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.teko(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: baseTextColor,
      ),
      displayMedium: GoogleFonts.teko(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: baseTextColor,
      ),
      displaySmall: GoogleFonts.teko(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseTextColor,
      ),
      headlineSmall: GoogleFonts.teko(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseTextColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseTextColor,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: CricketSpiritColors.mutedForeground,
      ),
      labelLarge: GoogleFonts.barlowCondensed(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: CricketSpiritColors.primary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CricketSpiritColors.background.withOpacity(0.8),
      foregroundColor: baseTextColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.teko(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: baseTextColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: CricketSpiritColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        side: const BorderSide(color: CricketSpiritColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CricketSpiritColors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: const BorderSide(color: CricketSpiritColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: const BorderSide(color: CricketSpiritColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: const BorderSide(color: CricketSpiritColors.ring),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: CricketSpiritColors.mutedForeground,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CricketSpiritColors.primary,
        foregroundColor: CricketSpiritColors.primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: baseTextColor,
        side: const BorderSide(color: CricketSpiritColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CricketSpiritColors.primary,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: CricketSpiritColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.dialog),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: CricketSpiritColors.white10,
      thickness: 1,
    ),
  );
}

