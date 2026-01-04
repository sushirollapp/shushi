import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart'; // For Colors
import 'package:flutter/services.dart'; // For keyboard

import '../../core/asset_paths.dart';
import '../../core/constants.dart';
import '../sushi_roll_rush_game.dart';

enum PlayerState {
  normal,
  hurt,
  happy,
}

class PlayerComponent extends SpriteGroupComponent<PlayerState>
    with HasGameReference<SushiRollRushGame>, CollisionCallbacks, KeyboardHandler {
  
  // Random
  final Random _random = Random();

  // Movement
  double _targetX = 0;
  int _lastLane = 1;
  
  // Growth
  static const double baseScale = 1.0;
  static const double maxScale = 1.5;
  static const double growthStep = 0.05; // 5% growth per ingredient
  
  // Dust Trail
  double _dustTimer = 0.0;
  
  // Visuals
  late final Sprite _normalSprite;
  late final Sprite _hurtSprite;
  late final Sprite _happySprite;
  
  PlayerComponent() : super(size: Vector2.all(64), anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load sprites
    _normalSprite = await game.loadSprite(AssetPaths.playerNormal.split('/').last);
    _hurtSprite = await game.loadSprite(AssetPaths.playerHurt.split('/').last);
    _happySprite = await game.loadSprite(AssetPaths.playerHappy.split('/').last);
    
    sprites = {
      PlayerState.normal: _normalSprite,
      PlayerState.hurt: _hurtSprite,
      PlayerState.happy: _happySprite,
    };
    
    current = PlayerState.normal;
    
    // Initial position
    _updateTargetPosition();
    position = Vector2(_targetX, game.size.y - 150);
    
    // Add hitbox
    add(CircleHitbox(radius: size.x / 2 * 0.8, anchor: Anchor.center, position: size / 2));
    
    // Set initial lane
    _lastLane = game.currentLane;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle lane changes
    if (game.currentLane != _lastLane) {
      _lastLane = game.currentLane;
      _updateTargetPosition();
      _playSquishAnimation();
    }
    
    // Smooth movement
    x = lerpDouble(x, _targetX, GameConstants.playerLerpSpeed) ?? x;
    
    // Dust Trail logic
    if (game.isPlaying && !game.isPaused && !game.isGameOver) {
      _dustTimer += dt;
      if (_dustTimer > 0.1) {
        _dustTimer = 0;
        _spawnDust();
      }
    }
  }
  
  void _spawnDust() {
    // Spawn dust at bottom of player
    // We add to game so it doesn't move with player X, but moves with world Y
    game.add(
      ParticleSystemComponent(
        priority: 5, // Behind player
        particle: AcceleratedParticle(
          position: position + Vector2(0, size.y / 2 - 10),
          speed: Vector2(0, game.effectiveScrollSpeed), // Move down with world
          lifespan: 0.6,
          child: CircleParticle(
            radius: 4 + _random.nextDouble() * 4,
            paint: Paint()..color = Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
  
  void _updateTargetPosition() {
    switch (game.currentLane) {
      case 0:
        _targetX = game.size.x / 2 + GameConstants.laneLeft;
        break;
      case 1:
        _targetX = game.size.x / 2 + GameConstants.laneCenter;
        break;
      case 2:
        _targetX = game.size.x / 2 + GameConstants.laneRight;
        break;
    }
  }
  
  void _playSquishAnimation() {
    // We base the squish on the current scale (which might be larger due to growth)
    final currentScale = scale.x; // Assumes x and y are roughly same base
    
    // Add a sequence of scale effects
    add(
      SequenceEffect(
        [
          ScaleEffect.to(
            Vector2(currentScale * 1.2, currentScale * 0.8),
            EffectController(duration: GameConstants.squishDuration / 2000), // ms to s
          ),
          ScaleEffect.to(
            Vector2(currentScale, currentScale),
            EffectController(duration: GameConstants.squishDuration / 2000),
          ),
        ],
      ),
    );
  }

  // Helper to change state temporarily
  void showState(PlayerState state, {Duration duration = const Duration(milliseconds: 500)}) {
    current = state;
    if (state != PlayerState.normal) {
      Future.delayed(duration, () {
        if (isMounted) {
          current = PlayerState.normal;
        }
      });
    }
  }
  
  /// Increase player size visually
  void grow() {
    // Calculate new scale
    double newScale = min(scale.x + growthStep, maxScale);
    
    // Apply smooth scaling effect
    add(
      ScaleEffect.to(
        Vector2.all(newScale),
        EffectController(duration: 0.2, curve: Curves.easeOutBack),
      ),
    );
  }
  
  /// Reset size
  void resetGrowth() {
    scale = Vector2.all(baseScale);
  }

  // ============================================
  // KEYBOARD CONTROLS (for web/desktop)
  // ============================================
  
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!game.isPlaying || game.isPaused) return false;
    
    // Handle key down events
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        game.moveLeft();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        game.moveRight();
        return true;
      }
    }
    
    return false;
  }
}
