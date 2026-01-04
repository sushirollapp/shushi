import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/game_colors.dart';
import '../core/app_theme.dart';
import '../game/sushi_roll_rush_game.dart';

class HudOverlay extends StatelessWidget {
  final SushiRollRushGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GameConstants.spacingMedium),
        child: Column(
          children: [
            // Top Row: Pause | Progress/Distance | Score
            Row(
              children: [
                // Pause Button
                _HudButton(
                  icon: Icons.pause_rounded,
                  onPressed: game.pauseGame,
                ),
                
                const SizedBox(width: GameConstants.spacingMedium),
                
                // Progress Bar (Level Mode) OR Distance Counter (Endless Mode)
                Expanded(
                  child: game.isEndlessMode
                      ? ValueListenableBuilder<int>(
                          valueListenable: game.distanceTraveled,
                          builder: (context, distance, child) {
                            return _DistanceBadge(distance: distance);
                          },
                        )
                      : ValueListenableBuilder<double>(
                          valueListenable: game.levelProgress,
                          builder: (context, progress, child) {
                            return _ProgressBar(progress: progress);
                          },
                        ),
                ),
                
                const SizedBox(width: GameConstants.spacingMedium),
                
                // Score Counter
                ValueListenableBuilder<int>(
                  valueListenable: game.score,
                  builder: (context, score, child) {
                    return _ScoreBadge(score: score);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HudButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: GameColors.noriBlack),
        onPressed: onPressed,
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(GameColors.matchaGreen),
        ),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  final int distance;

  const _DistanceBadge({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GameConstants.spacingMedium,
        vertical: GameConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: GameColors.tunaRed.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(GameConstants.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛤️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '${distance}m',
            style: const TextStyle(
              fontFamily: AppTheme.headlineFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GameConstants.spacingMedium,
        vertical: GameConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(GameConstants.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: const TextStyle(
              fontFamily: 'Sniglet',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GameColors.noriBlack,
            ),
          ),
        ],
      ),
    );
  }
}
