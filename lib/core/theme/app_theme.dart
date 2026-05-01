import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: Color(0xFF8B5CF6), // subtle purple accent
    onPrimary: Colors.white,

    secondary: Color(0xFF22C55E), // optional (rarely used)
    onSecondary: Colors.black,

    surface: Color(0xFF0B0B0F), // main background (NOT pure black)
    onSurface: Color(0xFFE5E7EB),

    surfaceContainerHighest: Color(0xFF1A1A22),
    onSurfaceVariant: Color(0xFF9CA3AF),

    outline: Color(0xFF2A2A35),

    error: Color(0xFFEF4444),
    onError: Colors.white,

    // Required but less used
    primaryContainer: Color(0xFF1E1B4B),
    onPrimaryContainer: Color(0xFFE0E7FF),

    secondaryContainer: Color(0xFF052E16),
    onSecondaryContainer: Color(0xFFBBF7D0),

    background: Color(0xFF0B0B0F),
    onBackground: Color(0xFFE5E7EB),

    surfaceVariant: Color(0xFF1F1F28),
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    primary: Color(0xFF6D28D9),
    onPrimary: Colors.white,

    secondary: Color(0xFF16A34A),
    onSecondary: Colors.white,

    surface: Color(0xFFF8F9FB), // soft white (NOT pure white)
    onSurface: Color(0xFF0F172A),

    surfaceContainerHighest: Color(0xFFE5E7EB),
    onSurfaceVariant: Color(0xFF6B7280),

    outline: Color(0xFFD1D5DB),

    error: Color(0xFFDC2626),
    onError: Colors.white,

    primaryContainer: Color(0xFFEDE9FE),
    onPrimaryContainer: Color(0xFF2E1065),

    secondaryContainer: Color(0xFFDCFCE7),
    onSecondaryContainer: Color(0xFF052E16),

    background: Color(0xFFF8F9FB),
    onBackground: Color(0xFF0F172A),

    surfaceVariant: Color(0xFFF1F5F9),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightColorScheme.background,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightColorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.background,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkColorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
