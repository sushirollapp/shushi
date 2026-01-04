import 'package:flutter/material.dart';
import 'game_colors.dart';
import 'constants.dart';

/// App theme configuration based on Design Language System
class AppTheme {
  AppTheme._();

  /// Font family for headlines (bubbly, rounded, fun)
  static const String headlineFont = 'Sniglet';

  /// Font family for body text (clean, readable, rounded)
  static const String bodyFont = 'Comfortaa';

  /// Main app theme
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: GameColors.salmonOrange,
        brightness: Brightness.light,
        surface: GameColors.riceWhite,
        onSurface: GameColors.noriBlack,
        primary: GameColors.salmonOrange,
        secondary: GameColors.matchaGreen,
        error: GameColors.tunaRed,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: GameColors.riceWhite,
      
      // Text theme
      textTheme: const TextTheme(
        // Headlines - Sniglet
        displayLarge: TextStyle(
          fontFamily: headlineFont,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: GameColors.noriBlack,
        ),
        displayMedium: TextStyle(
          fontFamily: headlineFont,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: GameColors.noriBlack,
        ),
        displaySmall: TextStyle(
          fontFamily: headlineFont,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GameColors.noriBlack,
        ),
        headlineMedium: TextStyle(
          fontFamily: headlineFont,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GameColors.noriBlack,
        ),
        
        // Body text - Comfortaa
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: GameColors.noriBlack,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GameColors.noriBlack,
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GameColors.noriBlack,
        ),
        
        // Labels
        labelLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: GameColors.noriBlack,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GameColors.matchaGreen,
          foregroundColor: GameColors.riceWhite,
          minimumSize: const Size(double.infinity, GameConstants.minButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: GameConstants.spacingLarge,
            vertical: GameConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameConstants.borderRadiusLarge),
          ),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          elevation: 4,
          shadowColor: Colors.black26,
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GameColors.salmonOrange,
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: GameColors.cardBackground,
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameConstants.borderRadiusMedium),
        ),
      ),
      
      // App bar theme (for settings screens, etc.)
      appBarTheme: const AppBarTheme(
        backgroundColor: GameColors.salmonOrange,
        foregroundColor: GameColors.riceWhite,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: headlineFont,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GameColors.riceWhite,
        ),
      ),
    );
  }
}

/// Custom button styles for the game
class GameButtonStyles {
  GameButtonStyles._();

  /// Primary action button (Play, Resume)
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: GameColors.matchaGreen,
    foregroundColor: GameColors.riceWhite,
    minimumSize: const Size(200, GameConstants.minButtonHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GameConstants.borderRadiusLarge),
    ),
  );

  /// Warning/Exit button (Quit, Home)
  static ButtonStyle warning = ElevatedButton.styleFrom(
    backgroundColor: GameColors.tunaRed,
    foregroundColor: GameColors.riceWhite,
    minimumSize: const Size(200, GameConstants.minButtonHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GameConstants.borderRadiusLarge),
    ),
  );

  /// Secondary button (Restart)
  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: GameColors.salmonOrange,
    foregroundColor: GameColors.riceWhite,
    minimumSize: const Size(200, GameConstants.minButtonHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GameConstants.borderRadiusLarge),
    ),
  );
}
