import 'package:flutter/material.dart';

import '../core/game_colors.dart';
import '../core/constants.dart';
import '../core/app_theme.dart';
import '../game/sushi_roll_rush_game.dart';

/// Pause menu overlay - "Lunch Break!"
class PauseMenuOverlay extends StatelessWidget {
  final SushiRollRushGame game;

  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.overlayBackground,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(GameConstants.spacingLarge),
          padding: const EdgeInsets.all(GameConstants.spacingSection),
          decoration: BoxDecoration(
            color: GameColors.riceWhite,
            borderRadius: BorderRadius.circular(GameConstants.borderRadiusMedium),
            boxShadow: [GameColors.standardShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Lunch Break!',
                style: TextStyle(
                  fontFamily: AppTheme.headlineFont,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: GameColors.noriBlack,
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingLarge),
              
              // Current score display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GameConstants.spacingLarge,
                  vertical: GameConstants.spacingMedium,
                ),
                decoration: BoxDecoration(
                  color: GameColors.woodLight,
                  borderRadius: BorderRadius.circular(GameConstants.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: GameConstants.spacingSmall),
                    Text(
                      'Score: ${game.score.value}',
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GameColors.noriBlack,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingSection),
              
              // Resume button (Green)
              ElevatedButton(
                onPressed: () => game.resumeGame(),
                style: GameButtonStyles.primary,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: GameConstants.spacingSmall),
                    Text('Resume'),
                  ],
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingMedium),
              
              // Restart button (Orange)
              ElevatedButton(
                onPressed: () => game.restartLevel(),
                style: GameButtonStyles.secondary,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: GameConstants.spacingSmall),
                    Text('Restart'),
                  ],
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingMedium),
              
              // Home button (Red)
              ElevatedButton(
                onPressed: () => game.goToMainMenu(),
                style: GameButtonStyles.warning,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: GameConstants.spacingSmall),
                    Text('Home'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
