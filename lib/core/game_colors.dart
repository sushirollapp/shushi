import 'package:flutter/material.dart';

/// Game color palette based on the Design Language System
/// Core Vibe: Kawaii, Tactile, Fresh, Juicy
class GameColors {
  GameColors._();

  // ============================================
  // PRIMARY BRAND COLORS
  // ============================================
  
  /// Rice White (Base) - Soft white, easier on the eyes than pure white
  static const Color riceWhite = Color(0xFFFAFAFA);
  
  /// Salmon Orange (Accent/Highlight) - Used for excitement, "New High Score"
  static const Color salmonOrange = Color(0xFFFF8A65);
  
  /// Nori Black (Text/Contrast) - Never use pure black
  static const Color noriBlack = Color(0xFF2D2D2D);

  // ============================================
  // FUNCTIONAL COLORS
  // ============================================
  
  /// Success Green (Play/Go) - Soft Matcha Green
  static const Color matchaGreen = Color(0xFF81C784);
  
  /// Warning Red (Exit/Danger) - Soft Tuna Red
  static const Color tunaRed = Color(0xFFE57373);
  
  /// Information Blue (Settings/Links)
  static const Color infoBlue = Color(0xFF64B5F6);

  // ============================================
  // BACKGROUND COLORS
  // ============================================
  
  /// Wood Light (Conveyor Belt) - Paper/Wood tint
  static const Color woodLight = Color(0xFFEFEBE9);
  
  /// Wood Dark (Edges)
  static const Color woodDark = Color(0xFFD7CCC8);

  // ============================================
  // UI OVERLAY COLORS
  // ============================================
  
  /// Semi-transparent overlay for menus
  static Color overlayBackground = Colors.black.withValues(alpha: 0.7);
  
  /// Card/Container background
  static Color cardBackground = Colors.white.withValues(alpha: 0.9);

  // ============================================
  // SHADOW CONFIGURATIONS
  // ============================================
  
  /// Standard shadow for UI elements
  static BoxShadow standardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
}
