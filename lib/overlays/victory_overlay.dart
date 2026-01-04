import 'package:flutter/material.dart';

import '../core/game_colors.dart';
import '../core/constants.dart';
import '../core/app_theme.dart';
import '../game/sushi_roll_rush_game.dart';

/// Victory overlay - Shown when the player reaches the finish line
class VictoryOverlay extends StatefulWidget {
  final SushiRollRushGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.game.calculateStars();
    final coinsEarned = widget.game.score.value ~/ 3; // Simple coin calculation

    return Container(
      color: GameColors.overlayBackground,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
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
                // Happy rice ball
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 60),
                ),
                
                const SizedBox(height: GameConstants.spacingMedium),
                
                // Title
                Text(
                  'Delicious!',
                  style: TextStyle(
                    fontFamily: AppTheme.headlineFont,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: GameColors.matchaGreen,
                  ),
                ),
                
                const SizedBox(height: GameConstants.spacingLarge),
                
                // Star display
                _StarDisplay(stars: stars),
                
                const SizedBox(height: GameConstants.spacingLarge),
                
                // Score and points earned
                Container(
                  padding: const EdgeInsets.all(GameConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: GameColors.woodLight,
                    borderRadius: BorderRadius.circular(GameConstants.borderRadiusSmall),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: GameConstants.spacingSmall),
                          Text(
                            'Score: ${widget.game.score.value}',
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFont,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: GameColors.noriBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GameConstants.spacingSmall),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: GameConstants.spacingSmall),
                          Text(
                            '+$coinsEarned pts',
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFont,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: GameColors.salmonOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: GameConstants.spacingSection),
                
                // Next level button (flashing)
                _NextLevelButton(onPressed: () => widget.game.nextLevel()),
                
                const SizedBox(height: GameConstants.spacingMedium),
                
                // Secondary options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => widget.game.restartLevel(),
                      child: Text(
                        'Replay',
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          color: GameColors.salmonOrange,
                        ),
                      ),
                    ),
                    const SizedBox(width: GameConstants.spacingLarge),
                    TextButton(
                      onPressed: () => widget.game.goToMainMenu(),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          color: GameColors.noriBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarDisplay extends StatelessWidget {
  final int stars;

  const _StarDisplay({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isFilled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? GameColors.salmonOrange : GameColors.woodDark,
            size: 48,
          ),
        );
      }),
    );
  }
}

class _NextLevelButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _NextLevelButton({required this.onPressed});

  @override
  State<_NextLevelButton> createState() => _NextLevelButtonState();
}

class _NextLevelButtonState extends State<_NextLevelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: GameButtonStyles.primary.copyWith(
              minimumSize: WidgetStateProperty.all(const Size(220, 60)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Next Level'),
                SizedBox(width: GameConstants.spacingSmall),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        );
      },
    );
  }
}
