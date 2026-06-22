import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D7377);
  static const Color primaryDark = Color(0xFF095456);
  static const Color accentColor = Color(0xFFF4A261);
  static const Color accentLight = Color(0xFFFFE8D6);
  static const Color backgroundColor = Color(0xFFF7F5F2);
  static const Color surfaceColor = Color(0xFFFFFCF9);
  static const Color textPrimary = Color(0xFF1A2B3C);
  static const Color textSecondary = Color(0xFF5C6B7A);
  static const Color borderColor = Color(0xFFE8E2DA);
  static const Color errorColor = Color(0xFFC0392B);
  static const Color successColor = Color(0xFF2D6A4F);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF14919B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDark, primaryColor, Color(0xFF14919B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextTheme get _textTheme =>
      GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      );

  static ThemeData get lightTheme {
    final textTheme = _textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleMedium?.copyWith(fontSize: 18),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: textPrimary,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }
}
