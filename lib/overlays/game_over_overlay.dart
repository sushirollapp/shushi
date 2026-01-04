import 'package:flutter/material.dart';

import '../core/game_colors.dart';
import '../core/constants.dart';
import '../core/app_theme.dart';
import '../game/sushi_roll_rush_game.dart';
import '../managers/data_manager.dart';

/// Game over overlay - Shown when the player fails badly
/// Note: This is a "soft fail" game, so this rarely appears
/// In endless mode, this is shown when the player loses all ingredients
class GameOverOverlay extends StatelessWidget {
  final SushiRollRushGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final isEndless = game.isEndlessMode;
    final isNewRecord = game.isNewRecord;
    final bestDistance = DataManager().endlessBestDistance;
    
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
              // Emoji based on mode and result
              Text(
                isEndless 
                    ? (isNewRecord ? '🏆' : '🛤️') 
                    : '😵',
                style: const TextStyle(fontSize: 80),
              ),
              
              const SizedBox(height: GameConstants.spacingMedium),
              
              // Title - different for endless mode
              Text(
                isEndless 
                    ? (isNewRecord ? 'NEW RECORD!' : 'Run Over!')
                    : 'Oops!',
                style: TextStyle(
                  fontFamily: AppTheme.headlineFont,
                  fontSize: isNewRecord ? 36 : 42,
                  fontWeight: FontWeight.bold,
                  color: isNewRecord ? GameColors.matchaGreen : GameColors.tunaRed,
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingSmall),
              
              Text(
                isEndless 
                    ? (isNewRecord ? 'You beat your best distance!' : 'The conveyor belt won...')
                    : 'The sushi fell apart...',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 18,
                  color: GameColors.noriBlack,
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingLarge),
              
              // Endless Mode: Distance display
              if (isEndless) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GameConstants.spacingLarge,
                    vertical: GameConstants.spacingMedium,
                  ),
                  decoration: BoxDecoration(
                    color: GameColors.tunaRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GameConstants.borderRadiusSmall),
                    border: Border.all(
                      color: GameColors.tunaRed.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🛤️', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: GameConstants.spacingSmall),
                          Text(
                            'Distance: ${game.distanceTraveled.value}m',
                            style: TextStyle(
                              fontFamily: AppTheme.headlineFont,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: GameColors.tunaRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GameConstants.spacingSmall),
                      Text(
                        'Best: ${bestDistance}m',
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontSize: 16,
                          color: GameColors.noriBlack.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: GameConstants.spacingMedium),
              ],
              
              // Score display
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
                      isEndless 
                          ? 'Points Earned: ${game.score.value}'
                          : 'Final Score: ${game.score.value}',
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GameColors.noriBlack,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingSection),
              
              // Try again button (Green)
              ElevatedButton(
                onPressed: () => game.restartLevel(),
                style: GameButtonStyles.primary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: GameConstants.spacingSmall),
                    Text(isEndless ? 'Try Again' : 'Try Again'),
                  ],
                ),
              ),
              
              const SizedBox(height: GameConstants.spacingMedium),
              
              // Home button
              TextButton(
                onPressed: () => game.goToMainMenu(),
                child: Text(
                  'Back to Menu',
                  style: TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 16,
                    color: GameColors.salmonOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
