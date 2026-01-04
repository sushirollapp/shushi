import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../sushi_roll_rush_game.dart';
import 'player_component.dart';

class ObstacleComponent extends SpriteComponent 
    with HasGameReference<SushiRollRushGame>, CollisionCallbacks {
  
  final String spritePath;
  bool _hasCollided = false;
  
  // Moving Obstacle Logic
  double _time = 0.0;
  bool _isMoving = false;
  double _initialX = 0.0;
  
  ObstacleComponent({
    required this.spritePath,
  }) : super(size: Vector2.all(56), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    sprite = await game.loadSprite(spritePath.split('/').last);
    
    // Add hitbox
    add(RectangleHitbox(
      size: size * 0.7, 
      anchor: Anchor.center, 
      position: size / 2,
    ));
    
    // Check for moving obstacles based on level config
    if (game.levelConfig.obstacleMoveSpeed > 0) {
      _isMoving = true;
      _initialX = position.x;
      // Randomize phase so they don't all move in sync
      _time = Random().nextDouble() * pi * 2;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move down based on scroll speed
    y += game.effectiveScrollSpeed * dt;
    
    // Horizontal Movement
    if (_isMoving) {
      _time += dt * game.levelConfig.obstacleMoveSpeed; // Dynamic speed
      // Dynamic range
      x = _initialX + sin(_time) * game.levelConfig.obstacleMoveRange;
    }
    
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
    
    if (other is PlayerComponent && !_hasCollided) {
      _hasCollided = true; // Prevent multiple hits
      game.hitObstacle();
      
      // Optional: Visual feedback on the obstacle itself (e.g. fade out or shake)
      // For now, we just remove it to prevent repeated collisions
      removeFromParent();
    }
  }
}
