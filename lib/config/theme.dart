import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SafeNet AI Design System - Light theme with blue accents
/// Based on the provided UI mockups
class AppTheme {
  // ── Brand Colors ──
  static const Color primaryBlue = Color(0xFF4A6CF7);
  static const Color primaryBlueDark = Color(0xFF3B5DE7);
  static const Color primaryBlueLight = Color(0xFF6B8AFF);
  static const Color accentPurple = Color(0xFF7C3AED);

  // ── Status Colors ──
  static const Color safeGreen = Color(0xFF22C55E);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color cautionYellow = Color(0xFFF59E0B);
  static const Color infoCyan = Color(0xFF06B6D4);

  // ── Neutral Colors ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  static const Color black = Color(0xFF0A0A0A);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A6CF7), Color(0xFF6B8AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF4A6CF7), Color(0xFF7C3AED)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Card Decoration ──
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get elevatedCard => BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ── Typography ──
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: grey900,
        height: 1.2,
      );

  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: grey900,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: grey900,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: grey900,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: grey600,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: grey600,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: grey500,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: grey800,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      );

  static TextStyle get brandText => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryBlue,
      );

  // ── Theme Data ──
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: background,
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ),
        fontFamily: GoogleFonts.inter().fontFamily,
        appBarTheme: AppBarTheme(
          backgroundColor: white,
          foregroundColor: grey900,
          elevation: 0,
          titleTextStyle: headingSmall,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: grey400,
          type: BottomNavigationBarType.fixed,
          elevation: 20,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: grey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: grey200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: grey200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: buttonText,
          ),
        ),
      );
}
