import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/game_colors.dart';

class FloatingTextComponent extends TextComponent {
  FloatingTextComponent({
    required String text,
    required Vector2 position,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontFamily: AppTheme.headlineFont,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: GameColors.salmonOrange,
              shadows: [
                Shadow(
                  color: Colors.white,
                  offset: Offset(0, 0),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Move up and scale down (fade effect via shrinking)
    add(
      MoveEffect.by(
        Vector2(0, -50),
        EffectController(duration: 0.8, curve: Curves.easeOut),
      ),
    );

    // Use ScaleEffect instead of OpacityEffect (TextComponent doesn't support OpacityProvider)
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.8, curve: Curves.easeIn),
        onComplete: removeFromParent,
      ),
    );
  }
}
