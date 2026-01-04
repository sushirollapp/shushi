import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../sushi_roll_rush_game.dart';
import 'player_component.dart';

class FinishLineComponent extends PositionComponent 
    with HasGameReference<SushiRollRushGame>, CollisionCallbacks {
  
  FinishLineComponent() : super(size: Vector2(400, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Visual representation: A checkered line or a "Goal" banner
    // For now, a simple rectangle with "FINISH" text
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white.withValues(alpha: 0.8),
    ));
    
    add(TextComponent(
      text: 'FINISH!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    ));
    
    add(RectangleHitbox(size: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down with the world
    y += game.effectiveScrollSpeed * dt;
    
    // If it passes the bottom, force level complete anyway just in case collision missed
    if (y > game.size.y + 100) {
      // If we missed collision for some reason, trigger it anyway
      if (!game.isVictory && !game.isGameOver) {
        game.levelComplete();
      }
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is PlayerComponent) {
      game.levelComplete();
    }
  }
}
