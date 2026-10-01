import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F0B1E); // Deep cosmic black/purple
  static const Color surface = Color(0xFF1E1838);    // Slightly lighter purple card background
  static const Color primary = Color(0xFF00C5E0);    // Electric cyan (slightly deeper for light mode contrast too)
  static const Color secondary = Color(0xFF9D4EDD);  // Deep purple accent
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA09DB0);
  static const Color error = Color(0xFFFF4C4C);

  // Gradient for wormhole effect and buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Light theme palette — retains same accent hues, inverts backgrounds/text.
class AppLightColors {
  static const Color background = Color(0xFFF4F2FF);       // Very light lavender-white
  static const Color surface = Color(0xFFFFFFFF);          // Pure white cards
  static const Color surfaceVariant = Color(0xFFEDE9FF);   // Subtle lavender for elevated cards
  static const Color primary = Color(0xFF0099B8);          // Slightly deeper cyan — readable on white
  static const Color secondary = Color(0xFF9D4EDD);        // Same deep-purple accent
  static const Color textPrimary = Color(0xFF12063A);      // Deep navy — excellent contrast on white
  static const Color textSecondary = Color(0xFF6B6480);    // Muted purple-grey
  static const Color error = Color(0xFFD0312D);            // Slightly deeper red for light bg
  static const Color divider = Color(0xFFDDD9EE);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Clinical futuristic palette for Live Human Health Monitoring Dashboard
class ClinicalColors {
  // Primary Clinical Backgrounds (Light cool gray with subtle blue/slate tint)
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTranslucent = Color(0xF2FFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Borders and Glassmorphic outlines
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEDF2F7);

  // Health-specific accents
  static const Color heart = Color(0xFFFF4D4F);        // Coral/Red pulse
  static const Color heartLight = Color(0xFFFFF1F0);   // Coral soft tint
  static const Color oxygen = Color(0xFF0284C7);       // Cyan/Blue oxygenation
  static const Color oxygenLight = Color(0xFFE0F2FE);  // Soft sky tint
  static const Color respiratory = Color(0xFF0D9488);  // Teal breathing
  static const Color healthy = Color(0xFF10B981);      // Emerald normal/optimal
  static const Color healthyLight = Color(0xFFECFDF5);  // Soft green tint
  static const Color warning = Color(0xFFF59E0B);      // Amber elevated/attention
  static const Color sleep = Color(0xFF6366F1);        // Indigo/Purple sleep recovery
  static const Color sleepLight = Color(0xFFEEF2FF);    // Soft indigo tint
  static const Color bloodPressure = Color(0xFF8B5CF6);// Violet BP
  static const Color circulationArtery = Color(0xFFFF5252);
  static const Color circulationVein = Color(0xFF38BDF8);

  // Clinical Slate Typography
  static const Color textPrimary = Color(0xFF0F172A);  // Deep slate
  static const Color textSecondary = Color(0xFF64748B);// Muted slate
  static const Color textTertiary = Color(0xFF94A3B8); // Subtle label slate

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
}
