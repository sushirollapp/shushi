import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../core/constants.dart';
import '../sushi_roll_rush_game.dart';
import 'player_component.dart';

class IngredientComponent extends SpriteComponent 
    with HasGameReference<SushiRollRushGame>, CollisionCallbacks {
  
  final String spritePath;
  final int points;
  
  IngredientComponent({
    required this.spritePath,
    this.points = GameConstants.ingredientPoints,
  }) : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    sprite = await game.loadSprite(spritePath.split('/').last);
    
    // Add hitbox slightly smaller than the sprite
    add(RectangleHitbox(
      size: size * 0.8, 
      anchor: Anchor.center, 
      position: size / 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down based on scroll speed
    y += game.effectiveScrollSpeed * dt;
    
    // Remove if off screen
    if (y > game.size.y + size.y) {
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
      game.collectIngredient(points);
      removeFromParent();
    }
  }
}
