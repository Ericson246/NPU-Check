import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cyberpunk Industrial theme for NeuralGauge
class AppTheme {
  // Neon Colors
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonBlue = Color(0xFF0080FF);
  static const Color neonGreen = Color(0xFF00FF41);
  static const Color neonOrange = Color(0xFFFF6B00);
  
  // Dark Background
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkBgSecondary = Color(0xFF151B2E);
  static const Color darkBgTertiary = Color(0xFF1F2937);
  
  // Accent Colors
  static const Color accentPrimary = neonCyan;
  static const Color accentSecondary = neonMagenta;
  static const Color accentDanger = neonOrange;
  
  // Text Colors
  static const Color textPrimary = Color(0xFFE0E7FF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  /// Get the main theme
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonMagenta,
        surface: darkBgSecondary,
        error: neonOrange,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.robotoMono(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.robotoMono(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.robotoMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: neonCyan,
          letterSpacing: 1.5,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: darkBgSecondary,
        elevation: 8,
        shadowColor: neonCyan.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: neonCyan.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: darkBg,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: neonCyan.withOpacity(0.5),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: neonCyan,
        size: 24,
      ),
    );
  }

  /// Glow effect for neon elements
  static List<BoxShadow> neonGlow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.6 * intensity),
        blurRadius: 20,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withOpacity(0.3 * intensity),
        blurRadius: 40,
        spreadRadius: 4,
      ),
    ];
  }

  /// Gradient for backgrounds
  static LinearGradient get darkGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        darkBg,
        darkBgSecondary,
        darkBgTertiary,
      ],
    );
  }

  /// Neon border
  static BoxDecoration neonBorder({
    Color color = neonCyan,
    double width = 2,
    double radius = 16,
  }) {
    return BoxDecoration(
      border: Border.all(color: color, width: width),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: neonGlow(color, intensity: 0.5),
    );
  }
}
