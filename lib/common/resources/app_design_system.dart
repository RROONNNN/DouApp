import 'package:flutter/material.dart';

/// Unified Design System for consistent UI across the app
class AppDesignSystem {
  // Color Palette - Material Design 3 inspired
  static const primaryGreen = Color(0xFF2E7D32);
  static const primaryGreenLight = Color(0xFF4CAF50);
  static const primaryGreenDark = Color(0xFF1B5E20);

  static const secondaryBlue = Color(0xFF1976D2);
  static const secondaryBlueLight = Color(0xFF42A5F5);
  static const secondaryBlueDark = Color(0xFF0D47A1);

  static const accentPurple = Color(0xFF7B1FA2);
  static const accentOrange = Color(0xFFFF6F00);

  static const successGreen = Color(0xFF2E7D32);
  static const errorRed = Color(0xFFD32F2F);
  static const warningOrange = Color(0xFFF57C00);

  static const surfaceWhite = Color(0xFFFFFFFF);
  static const surfaceGrey = Color(0xFFF5F5F5);
  static const surfaceLight = Color(0xFFFAFAFA);

  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textTertiary = Color(0xFF9E9E9E);

  // Gradients
  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreenLight, primaryGreen],
  );

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryBlueLight, secondaryBlue],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
  );

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), accentPurple],
  );

  // Spacing
  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing20 = 20.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;
  static const spacing40 = 40.0;
  static const spacing48 = 48.0;

  // Border Radius
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusXLarge = 20.0;
  static const radiusFull = 999.0;

  // Elevation
  static const elevationLow = 2.0;
  static const elevationMedium = 4.0;
  static const elevationHigh = 8.0;
  static const elevationXHigh = 12.0;

  // Animation Durations
  static const animationFast = Duration(milliseconds: 200);
  static const animationNormal = Duration(milliseconds: 300);
  static const animationSlow = Duration(milliseconds: 400);

  // Typography
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  // Shadows
  static List<BoxShadow> getShadow({double elevation = elevationMedium}) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: elevation,
        offset: Offset(0, elevation / 4),
      ),
    ];
  }

  static List<BoxShadow> get shadowLow => getShadow(elevation: elevationLow);
  static List<BoxShadow> get shadowMedium =>
      getShadow(elevation: elevationMedium);
  static List<BoxShadow> get shadowHigh => getShadow(elevation: elevationHigh);

  // Card Decoration
  static BoxDecoration cardDecoration({
    Color? color,
    Gradient? gradient,
    double? borderRadius,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: gradient == null ? (color ?? surfaceWhite) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
      boxShadow: shadows ?? shadowMedium,
      border: border,
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle({
    Color? backgroundColor,
    Gradient? gradient,
    double? elevation,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryGreen,
      foregroundColor: Colors.white,
      elevation: elevation ?? elevationMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  static ButtonStyle outlinedButtonStyle({Color? borderColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: borderColor ?? primaryGreen,
      side: BorderSide(color: borderColor ?? primaryGreen, width: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
