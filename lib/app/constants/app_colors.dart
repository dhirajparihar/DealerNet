import 'package:flutter/material.dart';

/// Design tokens following a strict 60-30-10 color rule.
/// 60% Muted, accessible semantic neutrals for surfaces.
/// 30% Distinct low-chroma primary colors.
/// 10% High-contrast call-to-action (CTA) accent tones.
class AppColors {
  AppColors._();

  // Primary brand palette (30% - Low-Chroma Primary: Deep Stone/Charcoal)
  static const Color primary = Color(0xFF1C1917); // Stone 900
  static const Color primaryLight = Color(0xFF292524); // Stone 800
  static const Color secondary = Color(0xFF78716C); // Stone 500
  
  // Action CTA Colors (10% - High-Contrast Accent: Crimson/Rose)
  static const Color accent = Color(0xFFE11D48); // Rose 600
  static const Color accentHover = Color(0xFFBE123C); // Rose 700
  static const Color error = Color(0xFFE11D48); // Rose 600

  // Surface & Background Architecture (60% - Tonal Layering: Neutrals)
  static const Color background = Color(0xFFF9FAFB); // Gray 50
  static const Color surface = Color(0xFFFFFFFF); // Pure White Surface
  static const Color surfaceMuted = Color(0xFFF3F4F6); // Gray 100
  static const Color surfaceContainerLow = Color(0xFFF3F4F6); // Gray 100
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB); // Gray 200
  static const Color border = Color(0xFFE5E7EB); // Subtle 1px Hairline Border
  static const Color borderDark = Color(0xFFD1D5DB); // Gray 300

  // Glassmorphism & Overlays
  static const Color glassWhite = Color(0xD9FFFFFF); // 85% opacity white
  static const Color glassObsidian = Color(0xCC1C1917); // 80% opacity dark
  static const Color shadowColor = Color(0x0A1C1917); // Ambient Diffused Light Shadow (4% opacity)

  // Typography Palette
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF4B5563); // Gray 600
  static const Color textMuted = Color(0xFF9CA3AF); // Gray 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Verification Palette
  static const Color statusAvailable = Color(0xFF059669); // Emerald 600
  static const Color statusAvailableBg = Color(0xFFD1FAE5); // Emerald 100
  static const Color statusReserved = Color(0xFFD97706); // Amber 600
  static const Color statusReservedBg = Color(0xFFFEF3C7); // Amber 100
  static const Color statusSold = Color(0xFF6B7280); // Gray 500
  static const Color statusSoldBg = Color(0xFFF3F4F6); // Gray 100
  static const Color statusDraft = Color(0xFF4F46E5); // Indigo 600
  static const Color statusDraftBg = Color(0xFFE0E7FF);
  static const Color statusExpired = Color(0xFFE11D48); // Rose 600
  static const Color statusExpiredBg = Color(0xFFFFE4E6);
  static const Color statusInfo = Color(0xFF0284C7); // Sky 600
  static const Color statusInfoBg = Color(0xFFE0F2FE);

  // Trust / Verification & Badge Highlights
  static const Color verified = Color(0xFF2563EB); // Royal Blue
  static const Color verifiedBg = Color(0xFFDBEAFE);
  static const Color goldAccent = Color(0xFFD97706); // Premium

  // Action CTA Colors (External)
  static const Color whatsapp = Color(0xFF16A34A);
  static const Color whatsappBg = Color(0xFFDCFCE7);
  static const Color whatsappBorder = Color(0xFF86EFAC);
  static const Color phoneCall = Color(0xFF2563EB);
}

